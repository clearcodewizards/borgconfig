require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "defines the public user attributes for an action" do
    policy = UserPolicy.new(users(:one), users(:one))
    expected_attributes = %i[id name role email_address created_at updated_at]

    assert_equal expected_attributes, policy.expected_attributes_for_action(:me)
  end

  test "admin scope includes every user" do
    admin = users(:one)
    admin.update!(role: :admin)

    resolved = UserPolicy::Scope.new(admin, User).resolve

    assert_equal User.order(:id).ids, resolved.order(:id).ids
  end

  test "non-admin scope includes only the current user" do
    member = users(:one)
    member.update!(role: :member)

    resolved = UserPolicy::Scope.new(member, User).resolve

    assert_equal [ member.id ], resolved.ids
  end
end
