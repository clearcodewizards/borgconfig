require "test_helper"

module Tools
  class RegisterCubesTest < ActiveSupport::TestCase
  setup do
    @admin = users(:one)
    @admin.update!(role: :admin)
    @context = { user_id: @admin.id }
  end

  test "registers one selected cube" do
    selected = Cube.create!(name: "Selected", api_token: "selected-token", registered: false)
    other = Cube.create!(name: "Other", api_token: "other-token", registered: false)

    response = Tools::RegisterCubes.call(server_context: @context, id: selected.id)
    cubes = JSON.parse(response.content.first[:text])

    assert_not response.error?
    assert_equal [ selected.id ], cubes.pluck("id")
    assert selected.reload.registered?
    assert_not other.reload.registered?
  end

  test "registers every unregistered cube" do
    first = Cube.create!(name: "First", api_token: "first-token", registered: false)
    second = Cube.create!(name: "Second", api_token: "second-token", registered: false)
    registered = Cube.create!(name: "Registered", api_token: "registered-token", registered: true)

    response = Tools::RegisterCubes.call(server_context: @context)
    cubes = JSON.parse(response.content.first[:text])

    assert_equal [ first.id, second.id ].sort, cubes.pluck("id").sort
    assert first.reload.registered?
    assert second.reload.registered?
    assert registered.reload.registered?
  end

  test "cannot update cubes outside the policy scope" do
    member = users(:two)
    member.update!(role: :member)
    cube = Cube.create!(name: "Cube", api_token: "cube-token", registered: false)

    response = Tools::RegisterCubes.call(server_context: { user_id: member.id })

    assert_equal [], JSON.parse(response.content.first[:text])
    assert_not cube.reload.registered?
  end
  end
end
