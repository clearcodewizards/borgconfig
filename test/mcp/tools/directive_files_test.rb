require "test_helper"

module Tools
  class DirectiveFilesTest < ActiveSupport::TestCase
    test "returns public directive filenames and descriptions" do
      response = Tools::DirectiveFiles.call
      directive_files = JSON.parse(response.content.first[:text]).index_by { |file| file.fetch("filename") }

      assert_not response.error?
      assert_equal %w[command.rb ping.rb], directive_files.keys.sort
      assert_equal "Run a command on a cube", directive_files.fetch("command.rb").fetch("description")
      assert_equal "Check if a cube is online", directive_files.fetch("ping.rb").fetch("description")
    end
  end
end
