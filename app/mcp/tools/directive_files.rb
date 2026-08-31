# frozen_string_literal: true

module Tools
  class DirectiveFiles < MCP::Tool
    description "Show directive files"

    def self.call(*)
      directive_files = DirectiveFile.all.keys.excluding("borg_client.rb").map do |filename|
        load Rails.root.join("lib/directives", filename)
        directive_class = Object.const_get(filename.delete_suffix(".rb").camelize)

        { filename:, description: directive_class.description }
      end

      MCP::Tool::Response.new([{ type: "text", text: directive_files.to_json }],
                              error: false)
    end
  end
end
