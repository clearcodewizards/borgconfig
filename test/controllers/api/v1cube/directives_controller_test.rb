require "test_helper"

module Api
  module V1cube
  class DirectivesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cube = Cube.create!(name: "Cube", api_token: "token", registered: true)
    @headers = { "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(@cube.api_token) }
  end

  test "lists only pending directives for the cube" do
    pending_directive = @cube.directives.create!(filename: "pending.rb")
    @cube.directives.create!(filename: "done.rb", status: :completed)
    other = Cube.create!(name: "Other", api_token: "other", registered: true)
    other.directives.create!(filename: "other.rb")

    get api_v1cube_directives_url, headers: @headers

    assert_response :ok
    assert_equal([ pending_directive.id ], response.parsed_body.pluck("id"))
  end

  test "shows a directive belonging to the cube" do
    directive = @cube.directives.create!(filename: "ping.rb")

    get api_v1cube_directive_url(directive), headers: @headers

    assert_response :ok
    assert_equal directive.id, response.parsed_body["id"]
  end

  test "does not show another cube's directive" do
    other = Cube.create!(name: "Other", api_token: "other", registered: true)
    directive = other.directives.create!(filename: "private.rb")

    get api_v1cube_directive_url(directive), headers: @headers

    assert_response :not_found
  end

  test "updates a directive" do
    directive = @cube.directives.create!(filename: "ping.rb")

    patch api_v1cube_directive_url(directive),
          params: { json: { status: "completed", output: "pong" } }, headers: @headers

    assert_response :ok
    assert directive.reload.completed?
    assert_equal "pong", directive.output
  end

  test "returns not found when updating a missing directive" do
    patch api_v1cube_directive_url(0),
          params: { json: { status: "completed", output: "pong" } }, headers: @headers

    assert_response :not_found
  end

  test "requires authentication" do
    get api_v1cube_directives_url

    assert_response :unauthorized
  end
  end
  end
end
