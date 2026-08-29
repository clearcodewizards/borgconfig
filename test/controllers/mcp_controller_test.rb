require "test_helper"

class MCPControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(api_token: "user-token")
  end

  test "rejects GET requests for an authenticated user" do
    get mcp_index_url, headers: token_header(@user.api_token)

    assert_response :method_not_allowed
  end

  test "requires a user token" do
    get mcp_index_url

    assert_response :unauthorized
  end

  test "requires a valid user token" do
    get mcp_index_url, headers: token_header("wrong-token")

    assert_response :unauthorized
  end

  test "handles an MCP initialize request" do
    post mcp_index_url,
         params: {
           jsonrpc: "2.0", id: 1, method: "initialize",
           params: { protocolVersion: "2025-03-26", capabilities: {}, clientInfo: { name: "test", version: "1.0" } }
         }.to_json,
         headers: token_header(@user.api_token).merge("Content-Type" => "application/json")

    assert_response :success
    assert_equal "2.0", response.parsed_body["jsonrpc"]
    assert_equal 1, response.parsed_body["id"]
  end

  private

  def token_header(token)
    { "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(token) }
  end
end
