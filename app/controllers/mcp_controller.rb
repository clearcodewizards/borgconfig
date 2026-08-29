class MCPController < ApplicationController
  include AuthenticatesUserByToken

  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token

  def index
    render json: {}, status: :method_not_allowed
  end

  def create
    server = MCP::Server.new(
      name: "borgconfig",
      title: "Borgconfig management tool. Let AI manage your infra.",
      version: "1.0.0",
      instructions: "Use the tools of this server for interacting with the borg collective",
      tools: [
        Tools::Me
      ],
      prompts: [],
      server_context: { user_id: @user.id }
    )
    transport = MCP::Server::Transports::StreamableHTTPTransport.new(
      server,
      stateless: true,
      dns_rebinding_protection: false
    )
    server.transport = transport
    status, headers, body = transport.handle_request(request)

    render json: body.first, status: status, headers: headers
  end
end
