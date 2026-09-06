# frozen_string_literal: true

module Tools
  class Me < MCP::Tool
    description "Show my user"

    def self.call(server_context:)
      user = User.find(server_context[:user_id])
      Pundit.authorize(user, user, :show?)
      attributes = Pundit.policy(user, user).expected_attributes_for_action(:me)
      MCP::Tool::Response.new([{ type: "text", text: user.to_json(only: attributes) }], error: false)
    rescue Pundit::NotAuthorizedError
      MCP::Tool::Response.new([{ type: "text", text: "Not authorized to view your user." }], error: true)
    end
  end
end
