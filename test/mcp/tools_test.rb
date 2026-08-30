require "test_helper"

class ToolsTest < ActiveSupport::TestCase
  setup do
    @admin = users(:one)
    @admin.update!(role: :admin)
    @context = { user_id: @admin.id }
  end

  test "cubes filters by id, partial name, and tag" do
    tag = Tag.create!(name: "test")
    matching = Cube.create!(name: "Test worker", api_token: "matching-token", tags: [ tag ])
    Cube.create!(name: "Other worker", api_token: "other-token")

    response = Tools::Cubes.call(server_context: @context, id: matching.id, name: "st work", tag: "test")
    cubes = JSON.parse(response.content.first[:text])

    assert_not response.error?
    assert_equal [ matching.id ], cubes.pluck("id")
    assert_equal [ "test" ], cubes.first.fetch("tags").pluck("name")
  end

  test "cubes returns all authorized cubes without filters" do
    Cube.create!(name: "Worker", api_token: "worker-token")

    cubes = JSON.parse(Tools::Cubes.call(server_context: @context).content.first[:text])

    assert_equal Cube.order(:id).ids, cubes.pluck("id").sort
  end

  test "directives optionally filters by id" do
    cube = Cube.create!(name: "Cube", api_token: "cube-token")
    matching = cube.directives.create!(filename: "ping.rb")
    cube.directives.create!(filename: "borg_client.rb")

    directives = JSON.parse(Tools::Directives.call(server_context: @context, id: matching.id).content.first[:text])

    assert_equal [ matching.id ], directives.pluck("id")
    assert_equal({ "id" => cube.id, "name" => "Cube" }, directives.first.fetch("cube"))
  end

  test "directives returns all authorized directives without an id" do
    cube = Cube.create!(name: "Cube", api_token: "cube-token")
    cube.directives.create!(filename: "ping.rb")

    directives = JSON.parse(Tools::Directives.call(server_context: @context).content.first[:text])

    assert_equal Directive.order(:id).ids, directives.pluck("id").sort
  end

  test "create directives selects cubes by ids and tags" do
    tag = Tag.create!(name: "test")
    by_id = Cube.create!(name: "By ID", api_token: "id-token")
    by_tag = Cube.create!(name: "By tag", api_token: "tag-token", tags: [ tag ])

    response = Tools::CreateDirectives.call(
      server_context: @context,
      filename: "ping.rb",
      cube_ids: [ by_id.id ],
      tags: [ "test" ]
    )
    directive_ids = JSON.parse(response.content.first[:text])

    assert_not response.error?
    assert_equal [ by_id.id, by_tag.id ], Directive.where(id: directive_ids).order(:cube_id).pluck(:cube_id)
  end

  test "create directives creates nothing without cube selectors" do
    assert_no_difference "Directive.count" do
      response = Tools::CreateDirectives.call(server_context: @context, filename: "ping.rb")
      assert_equal [], JSON.parse(response.content.first[:text])
    end
  end

  test "tags serializes tag names" do
    Tag.create!(name: "test")

    tags = JSON.parse(Tools::Tags.call.content.first[:text])

    assert_equal [ "test" ], tags.pluck("name")
  end

  test "me serializes the current user" do
    user = JSON.parse(Tools::Me.call(server_context: @context).content.first[:text])

    assert_equal @admin.id, user.fetch("id")
    assert_equal "admin", user.fetch("role")
  end
end
