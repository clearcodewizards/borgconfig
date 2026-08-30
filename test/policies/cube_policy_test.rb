require "test_helper"

class CubePolicyTest < ActiveSupport::TestCase
  test "defines cube attributes exposed by tools" do
    assert_equal %i[id name registered status created_at updated_at],
                 CubePolicy.new(users(:one), Cube.new).expected_attributes_for_action(:show)
  end

  test "admin scope includes cubes" do
    admin = users(:one)
    admin.update!(role: :admin)
    cube = Cube.create!(name: "Cube", api_token: "cube-token")

    assert_includes CubePolicy::Scope.new(admin, Cube).resolve, cube
  end

  test "non-admin scope excludes cubes" do
    member = users(:one)
    member.update!(role: :member)
    Cube.create!(name: "Cube", api_token: "cube-token")

    assert_empty CubePolicy::Scope.new(member, Cube).resolve
  end
end
