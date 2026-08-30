# frozen_string_literal: true

module Tools
  class Directives < MCP::Tool
    description "Show directives"
    input_schema(
      properties: {
        id: { type: "integer" }
      }
    )

    def self.call(server_context:, id: nil)
      user = User.find(server_context[:user_id])
      directives = Pundit.policy_scope(user, Directive)

      directives = directives.where(id: id) if id

      attributes = Pundit.policy(user, Directive).expected_attributes_for_action(:show)
      MCP::Tool::Response.new([{ type: "text", text: directives.to_json(include: { cube: { only: %i[id name] } },
                                                                        only: attributes) }],
                              error: false)
    end
  end
end
