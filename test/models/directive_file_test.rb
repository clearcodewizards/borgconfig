require "test_helper"

class DirectiveFileTest < ActiveSupport::TestCase
  test "returns ruby files encoded as base64" do
    files = DirectiveFile.all

    assert_not_empty files
    files.each do |filename, encoded_content|
      assert_equal Rails.root.join("lib/directives", filename).binread,
                   Base64.strict_decode64(encoded_content)
    end
  end
end
