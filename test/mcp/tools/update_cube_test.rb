require "test_helper"

module Tools
  class UpdateCubeTest < ActiveSupport::TestCase
  setup do
    admin = users(:one)
    admin.update!(role: :admin)
    @context = { user_id: admin.id }
  end

  test "changes its name and adds new and existing tags" do
    existing_tag = Tag.create!(name: "existing")
    original_tag = Tag.create!(name: "original")
    cube = Cube.create!(name: "Old name", api_token: "cube-token", tags: [ original_tag ])

    assert_difference "Tag.count", 1 do
      response = Tools::UpdateCube.call(
        server_context: @context,
        id: cube.id,
        name: "New name",
        tags: %w[existing new]
      )
      result = JSON.parse(response.content.first[:text])

      assert_not response.error?
      assert_equal "New name", result.fetch("name")
      assert_equal %w[existing new original], result.fetch("tags").pluck("name").sort
    end

    assert_equal "New name", cube.reload.name
    assert_equal [ existing_tag.id, original_tag.id, Tag.find_by!(name: "new").id ].sort, cube.tag_ids.sort
  end

  test "leaves omitted attributes unchanged" do
    tag = Tag.create!(name: "original")
    cube = Cube.create!(name: "Cube", api_token: "cube-token", tags: [ tag ])

    Tools::UpdateCube.call(server_context: @context, id: cube.id)

    assert_equal "Cube", cube.reload.name
    assert_equal [ tag ], cube.tags
  end
  end
end
