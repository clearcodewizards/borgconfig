# frozen_string_literal: true

module Tools
  class RegisterCubes < MCP::Tool
    description "Register cubes"
    input_schema(
      properties: {
        id: { type: "integer" }
      }
    )

    def self.call(server_context:, id: nil)
      user = User.find(server_context[:user_id])
      cubes = Pundit.policy_scope(user, Cube)

      cubes = if id
        cubes.where(id: id)
      else
        cubes.where(registered: false)
      end

      cubes.each do |cube|
        cube.update!(registered: true)
      end

      attributes = Pundit.policy(user, Cube).expected_attributes_for_action(:show)
      MCP::Tool::Response.new([{ type: "text",
                                 text: cubes.to_json(only: attributes,
                                                     include: { tags: { only: :name } }) }],
                              error: false)
    end
  end
end
