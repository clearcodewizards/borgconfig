# frozen_string_literal: true

module Tools
  class Me < MCP::Tool
    description "Get my user"

    def self.call(server_context:)
      user = User.find(server_context[:user_id])
      attributes = Pundit.policy(user, user).expected_attributes_for_action(:me)
      MCP::Tool::Response.new([ { type: "text", text: user.to_json(only: attributes) } ], error: false)
    end
  end
end
