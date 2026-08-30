require "test_helper"

module Api
  module V1cube
  class CubesControllerTest < ActionDispatch::IntegrationTest
  test "registers a new cube token" do
    assert_difference "Cube.count", 1 do
      post api_v1cube_cubes_url, headers: token_header("new-token")
    end

    assert_response :ok
    assert Cube.find_by!(api_token: "new-token").pending?
  end

  test "creates and attaches tags to a new cube" do
    assert_difference({ "Cube.count" => 1, "Tag.count" => 2, "CubeTag.count" => 2 }) do
      post api_v1cube_cubes_url,
           params: { tags: %w[linux x86_64] },
           headers: token_header("tagged-token"),
           as: :json
    end

    assert_response :ok
    assert_equal %w[linux x86_64], Cube.find_by!(api_token: "tagged-token").tags.order(:name).pluck(:name)
  end

  test "reuses existing tags and does not duplicate attachments" do
    existing_tag = Tag.create!(name: "linux")

    assert_difference "Cube.count", 1 do
      assert_difference "Tag.count", 1 do
        assert_difference "CubeTag.count", 2 do
          post api_v1cube_cubes_url,
               params: { tags: %w[linux linux x86_64] },
               headers: token_header("tagged-token"),
               as: :json
        end
      end
    end

    cube = Cube.find_by!(api_token: "tagged-token")
    assert_includes cube.tags, existing_tag

    assert_no_difference [ "Cube.count", "Tag.count", "CubeTag.count" ] do
      post api_v1cube_cubes_url,
           params: { tags: %w[linux x86_64] },
           headers: token_header("tagged-token"),
           as: :json
    end

    assert_response :ok

    assert_difference({ "Tag.count" => 1, "CubeTag.count" => 1 }) do
      post api_v1cube_cubes_url,
           params: { tags: [ "arm64" ] },
           headers: token_header("tagged-token"),
           as: :json
    end

    assert_equal %w[arm64 linux x86_64], cube.tags.reload.order(:name).pluck(:name)
  end

  test "does not duplicate an existing cube" do
    Cube.create!(name: "Cube", api_token: "existing-token")

    assert_no_difference "Cube.count" do
      post api_v1cube_cubes_url, headers: token_header("existing-token")
    end

    assert_response :ok
  end

  test "rejects registration without a token" do
    assert_no_difference "Cube.count" do
      post api_v1cube_cubes_url
    end

    assert_response :unauthorized
  end

  test "returns the registered cube" do
    cube = Cube.create!(name: "Cube", api_token: "token", registered: true)

    get api_v1cube_cubes_url, headers: token_header(cube.api_token)

    assert_response :ok
    assert_equal cube.id, response.parsed_body["id"]
  end

  test "rejects an unregistered cube" do
    cube = Cube.create!(name: "Cube", api_token: "token", registered: false)

    get api_v1cube_cubes_url, headers: token_header(cube.api_token)

    assert_response :unauthorized
  end

    private

  def token_header(token)
    { "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(token) }
  end
  end
  end
end
