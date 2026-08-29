require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  test "delegates user to the current session" do
    Current.session = users(:one).sessions.create!

    assert_equal users(:one), Current.user
  ensure
    Current.reset
  end

  test "has no user without a session" do
    Current.session = nil

    assert_nil Current.user
  ensure
    Current.reset
  end
end
