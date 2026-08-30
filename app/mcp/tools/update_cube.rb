# frozen_string_literal: true

module Tools
  class UpdateCube < MCP::Tool
    description "Update cube"
    input_schema(
      properties: {
        id: { type: "integer" },
        name: { type: "string" },
        tags: { type: "array", items: { type: "string" }}
      },
      required: ["id"]
    )

    def self.call(server_context:, id:, name: nil, tags: nil)
      user = User.find(server_context[:user_id])
      cubes = Pundit.policy_scope(user, Cube)

      cube = cubes.find_by(id: id)
      cube.name = name if name

      if tags
        tags = tags.map { |name| Tag.find_or_create_by!(name:) }
        cube.tags = (cube.tags.to_a + tags).uniq
      end

      cube.save!

      attributes = Pundit.policy(user, Cube).expected_attributes_for_action(:show)
      MCP::Tool::Response.new([{ type: "text",
                                 text: cube.to_json(only: attributes,
                                                    include: { tags: { only: :name } }) }],
                              error: false)
    end
  end
end
