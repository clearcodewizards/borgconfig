require "test_helper"

module Tools
  class AuthorizationTest < ActiveSupport::TestCase
    test "guests receive authorization errors from every read tool" do
      user = users(:one)
      user.update!(role: :guest)
      context = { user_id: user.id }

      [ Me, Cubes, Directives, Tags, DirectiveFiles ].each do |tool|
        response = tool.call(server_context: context)
        assert response.error?, "#{tool.name} should deny guests"
        assert_match "Not authorized", response.content.first[:text]
      end

      [ Cubes, Directives ].each do |tool|
        assert tool.call(server_context: context, id: 1).error?
      end
    end

    test "members cannot mutate cubes or create directives" do
      user = users(:one)
      user.update!(role: :member)
      context = { user_id: user.id }
      cube = Cube.create!(name: "Original", api_token: "authorization-token", registered: false)

      assert_no_difference [ "Directive.count", "Tag.count" ] do
        assert CreateDirectives.call(server_context: context, filename: "ping.rb", arguments: "",
                                     cube_ids: [ cube.id ]).error?
        assert RegisterCubes.call(server_context: context, id: cube.id).error?
        assert UpdateCube.call(server_context: context, id: cube.id, name: "Changed", tags: [ "new" ]).error?
      end

      assert_equal "Original", cube.reload.name
      assert_not cube.registered?
    end

    test "permitted read actions still respect policy scopes" do
      user = users(:one)
      user.update!(role: :member)
      context = { user_id: user.id }
      cube = Cube.create!(name: "Outside scope", api_token: "outside-scope-token")
      directive = cube.directives.create!(filename: "ping.rb")

      [ [ Cubes, cube.id ], [ Directives, directive.id ] ].each do |tool, id|
        [ {}, { id: id } ].each do |filters|
          response = tool.call(server_context: context, **filters)
          assert_not response.error?
          assert_equal [], JSON.parse(response.content.first[:text])
        end
      end
    end
  end
end
