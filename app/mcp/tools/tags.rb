# frozen_string_literal: true

module Tools
  class Tags < MCP::Tool
    description "Show tags"

    def self.call(server_context:)
      user = User.find(server_context[:user_id])
      Pundit.authorize(user, Tag, :index?)

      MCP::Tool::Response.new([{ type: "text",
                                 text: Tag.all.to_json(only: :name) }],
                              error: false)
    rescue Pundit::NotAuthorizedError
      MCP::Tool::Response.new([{ type: "text", text: "Not authorized to view tags." }], error: true)
    end
  end
end
