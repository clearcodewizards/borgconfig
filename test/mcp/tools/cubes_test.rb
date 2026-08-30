require "test_helper"

module Tools
  class CubesTest < ActiveSupport::TestCase
  setup do
    @admin = users(:one)
    @admin.update!(role: :admin)
    @context = { user_id: @admin.id }
  end

  test "filters by id, partial name, and tag" do
    tag = Tag.create!(name: "test")
    matching = Cube.create!(name: "Test worker", api_token: "matching-token", tags: [ tag ])
    Cube.create!(name: "Other worker", api_token: "other-token")

    response = Tools::Cubes.call(server_context: @context, id: matching.id, name: "st work", tag: "test")
    cubes = JSON.parse(response.content.first[:text])

    assert_not response.error?
    assert_equal [ matching.id ], cubes.pluck("id")
    assert_equal [ "test" ], cubes.first.fetch("tags").pluck("name")
  end

  test "returns all authorized cubes without filters" do
    Cube.create!(name: "Worker", api_token: "worker-token")

    cubes = JSON.parse(Tools::Cubes.call(server_context: @context).content.first[:text])

    assert_equal Cube.order(:id).ids, cubes.pluck("id").sort
  end
  end
end
