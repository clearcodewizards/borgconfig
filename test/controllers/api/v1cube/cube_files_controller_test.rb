require "test_helper"

module Api
  module V1cube
  class CubeFilesControllerTest < ActionDispatch::IntegrationTest
  test "returns cube files to a registered cube" do
    cube = Cube.create!(name: "Cube", api_token: "token", registered: true)
    headers = { "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(cube.api_token) }

    get api_v1cube_cube_files_url, headers: headers

    assert_response :ok
    assert_equal CubeFile.all, response.parsed_body
  end

  test "requires authentication" do
    get api_v1cube_cube_files_url

    assert_response :unauthorized
  end
  end
  end
end
