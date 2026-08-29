require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "shows the password reset form" do
    get new_password_url

    assert_response :success
  end

  test "queues reset instructions for an existing user" do
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ users(:one) ] do
      post passwords_url, params: { email_address: users(:one).email_address }
    end

    assert_redirected_to new_session_url
  end

  test "does not reveal an unknown email address" do
    assert_no_enqueued_emails do
      post passwords_url, params: { email_address: "unknown@example.com" }
    end

    assert_redirected_to new_session_url
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "shows the reset form with a valid token" do
    get edit_password_url(users(:one).generate_token_for(:password_reset))

    assert_response :success
  end

  test "redirects an invalid token" do
    get edit_password_url("invalid")

    assert_redirected_to new_password_url
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "updates the password" do
    token = users(:one).generate_token_for(:password_reset)

    patch password_url(token), params: { password: "new password", password_confirmation: "new password" }

    assert_redirected_to new_session_url
    assert users(:one).reload.authenticate("new password")
  end

  test "rejects mismatched passwords" do
    token = users(:one).generate_token_for(:password_reset)

    patch password_url(token), params: { password: "new password", password_confirmation: "different" }

    assert_redirected_to edit_password_url(token)
    assert_equal "Passwords did not match.", flash[:alert]
  end
end
