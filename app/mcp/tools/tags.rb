# frozen_string_literal: true

module Tools
  class Tags < MCP::Tool
    description "Show tags"

    def self.call(*)
      MCP::Tool::Response.new([{ type: "text",
                                 text: Tag.all.to_json(only: :name) }],
                              error: false)
    end
  end
end
