# frozen_string_literal: true

module Tools
  class CreateDirectives < MCP::Tool
    description "Create directives"
    input_schema(
      properties: {
        filename: { type: "string" },
        cube_ids: { type: "array", items: { type: "integer" }},
        tags: { type: "array", items: { type: "string" }}
      },
      required: ["filename"]
    )

    def self.call(server_context:, filename:, cube_ids: nil, tags: nil)
      user = User.find(server_context[:user_id])
      cubes = Pundit.policy_scope(user, Cube)

      filtered_cubes = []
      filtered_cubes = cubes.where(id: cube_ids) if cube_ids
      tags&.each do |tag|
        filtered_cubes += cubes.tagged_with(tag)
      end

      directive_ids = []
      filtered_cubes&.each do |cube|
        directive = Directive.create!(cube:, filename:)
        directive_ids << directive.id
      end

      MCP::Tool::Response.new([{ type: "text", text: directive_ids.to_json }],
                              error: false)
    end
  end
end
