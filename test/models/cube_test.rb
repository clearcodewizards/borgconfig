require "test_helper"

class CubeTest < ActiveSupport::TestCase
  test "supports every status" do
    assert_equal %w[pending in_progress completed], Cube.statuses.keys
  end

  test "requires a unique api token" do
    Cube.create!(name: "First", api_token: "shared-token")
    duplicate = Cube.new(name: "Second", api_token: "shared-token")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:api_token], "has already been taken"
  end

  test "encrypts the api token in the database" do
    cube = Cube.create!(name: "Cube", api_token: "plain-token")

    assert_equal "plain-token", cube.api_token
    assert_not_equal "plain-token", cube.read_attribute_before_type_cast(:api_token)
  end

  test "destroying a cube destroys its directives" do
    cube = Cube.create!(name: "Cube", api_token: "token")
    directive = cube.directives.create!(filename: "ping.rb")

    cube.destroy!

    assert_not Directive.exists?(directive.id)
  end
end
