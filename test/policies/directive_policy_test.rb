require "test_helper"

class DirectivePolicyTest < ActiveSupport::TestCase
  test "defines directive attributes exposed by tools" do
    assert_equal %i[id status filename arguments output created_at updated_at],
      DirectivePolicy.new(users(:one), Directive.new).expected_attributes_for_action(:show)
  end

  test "admin scope includes directives" do
    admin = users(:one)
    admin.update!(role: :admin)
    cube = Cube.create!(name: "Cube", api_token: "cube-token")
    directive = cube.directives.create!(filename: "ping.rb")

    assert_includes DirectivePolicy::Scope.new(admin, Directive).resolve, directive
  end

  test "non-admin scope excludes directives" do
    member = users(:one)
    member.update!(role: :member)
    cube = Cube.create!(name: "Cube", api_token: "cube-token")
    cube.directives.create!(filename: "ping.rb")

    assert_empty DirectivePolicy::Scope.new(member, Directive).resolve
  end
end
