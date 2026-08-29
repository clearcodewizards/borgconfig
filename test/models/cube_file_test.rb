require "test_helper"

class CubeFileTest < ActiveSupport::TestCase
  test "returns ruby files encoded as base64" do
    files = CubeFile.all

    assert_not_empty files
    files.each do |filename, encoded_content|
      assert_equal Rails.root.join("storage/cube_files", filename).binread,
                   Base64.strict_decode64(encoded_content)
    end
  end
end
