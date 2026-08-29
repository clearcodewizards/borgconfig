require "test_helper"

class CubesControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to sign in" do
    get root_url

    assert_redirected_to new_session_url
  end

  test "shows cubes to an authenticated user" do
    post session_url, params: { email_address: users(:one).email_address, password: "password" }

    get root_url

    assert_response :success
  end
end
