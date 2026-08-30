# frozen_string_literal: true

module Tools
  class Cubes < MCP::Tool
    description "Show cubes"
    input_schema(
      properties: {
        id: { type: "integer" },
        name: { type: "string" },
        tag: { type: "string" }
      }
    )

    def self.call(server_context:, id: nil, name: nil, tag: nil)
      user = User.find(server_context[:user_id])
      cubes = Pundit.policy_scope(user, Cube)

      cubes = cubes.where(id: id) if id
      cubes = cubes.where(
        "cubes.name LIKE ?",
        "%#{Cube.sanitize_sql_like(name)}%"
      ) if name
      cubes = cubes.tagged_with(tag) if tag

      attributes = Pundit.policy(user, Cube).expected_attributes_for_action(:show)
      MCP::Tool::Response.new([{ type: "text",
                                 text: cubes.to_json(only: attributes,
                                                     include: { tags: { only: :name } }) }],
                              error: false)
    end
  end
end
