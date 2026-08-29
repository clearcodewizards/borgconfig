require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "shows the sign in form" do
    get new_session_url

    assert_response :success
  end

  test "creates a session with valid credentials" do
    assert_difference "users(:one).sessions.count", 1 do
      post session_url, params: { email_address: users(:one).email_address, password: "password" }
    end

    assert_redirected_to root_url
  end

  test "rejects invalid credentials" do
    assert_no_difference "Session.count" do
      post session_url, params: { email_address: users(:one).email_address, password: "wrong" }
    end

    assert_redirected_to new_session_url
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "destroys the current session" do
    post session_url, params: { email_address: users(:one).email_address, password: "password" }

    assert_difference "Session.count", -1 do
      delete session_url
    end

    assert_redirected_to new_session_url
  end
end
