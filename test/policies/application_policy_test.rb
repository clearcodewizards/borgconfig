require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  setup do
    @policy = ApplicationPolicy.new(users(:one), users(:two))
  end

  test "denies every base action" do
    assert_not @policy.index?
    assert_not @policy.show?
    assert_not @policy.create?
    assert_not @policy.new?
    assert_not @policy.update?
    assert_not @policy.edit?
    assert_not @policy.destroy?
  end

  test "new delegates to create" do
    @policy.define_singleton_method(:create?) { true }

    assert @policy.new?
  end

  test "edit delegates to update" do
    @policy.define_singleton_method(:update?) { true }

    assert @policy.edit?
  end

  test "base scope requires subclasses to implement resolve" do
    policy_scope = ApplicationPolicy::Scope.new(users(:one), User)

    error = assert_raises(NoMethodError) { policy_scope.resolve }
    assert_equal "You must define #resolve in ApplicationPolicy::Scope", error.message
  end
end
