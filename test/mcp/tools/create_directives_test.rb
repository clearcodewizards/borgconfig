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
  end
end
