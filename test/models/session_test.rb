require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "belongs to a user" do
    session = Session.new

    assert_not session.valid?
    assert_includes session.errors[:user], "must exist"
  end

  test "stores request metadata" do
    session = users(:one).sessions.create!(ip_address: "127.0.0.1", user_agent: "Test browser")

    assert_equal "127.0.0.1", session.ip_address
    assert_equal "Test browser", session.user_agent
  end
end
