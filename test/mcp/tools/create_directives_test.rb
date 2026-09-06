require "test_helper"

module Tools
  class CreateDirectivesTest < ActiveSupport::TestCase
  setup do
    admin = users(:one)
    admin.update!(role: :admin)
    @context = { user_id: admin.id }
  end

  test "selects cubes by ids and tags" do
    tag = Tag.create!(name: "test")
    by_id = Cube.create!(name: "By ID", api_token: "id-token")
    by_tag = Cube.create!(name: "By tag", api_token: "tag-token", tags: [ tag ])

    response = Tools::CreateDirectives.call(
      server_context: @context,
      filename: "ping.rb",
      arguments: "",
      cube_ids: [ by_id.id ],
      tags: [ "test" ]
    )
    directive_ids = JSON.parse(response.content.first[:text])

    assert_not response.error?
    assert_equal [ by_id.id, by_tag.id ], Directive.where(id: directive_ids).order(:cube_id).pluck(:cube_id)
  end

  test "creates nothing without cube selectors" do
    assert_no_difference "Directive.count" do
      response = Tools::CreateDirectives.call(server_context: @context, filename: "ping.rb", arguments: "")
      assert_equal [], JSON.parse(response.content.first[:text])
    end
  end

  test "allows the exact required role" do
    cube = Cube.create!(name: "Command cube", api_token: "command-role-token")

    assert_difference "Directive.count", 1 do
      response = Tools::CreateDirectives.call(server_context: @context, filename: "command.rb",
                                              arguments: "whoami", cube_ids: [ cube.id ])
      assert_not response.error?
    end
  end

  test "rejects users below the directive role" do
    user = users(:one)
    user.update!(role: :manager)

    assert_no_difference "Directive.count" do
      response = Tools::CreateDirectives.call(server_context: @context, filename: "command.rb", arguments: "")
      assert response.error?
      assert_match "role does not meet", response.content.first[:text]
    end
  end

  test "rejects unknown files and files without a role" do
    [ "missing.rb", "../directives/ping.rb" ].each do |filename|
      assert_no_difference "Directive.count" do
        response = Tools::CreateDirectives.call(server_context: @context, filename: filename, arguments: "")
        assert response.error?
      end
    end
  end

  test "rejects invalid roles" do
    path = Rails.root.join("lib/directives", "invalid_role_#{Process.pid}.rb")
    begin
      File.write(path, "class InvalidRole#{Process.pid}; def self.role; :unknown; end; end")
      assert_no_difference "Directive.count" do
        response = Tools::CreateDirectives.call(server_context: @context, filename: path.basename.to_s, arguments: "")
        assert response.error?
      end
    ensure
      File.delete(path) if path.exist?
    end
  end
  end
end
