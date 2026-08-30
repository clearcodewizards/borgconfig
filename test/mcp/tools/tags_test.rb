require "test_helper"

module Tools
  class TagsTest < ActiveSupport::TestCase
  test "serializes tag names" do
    Tag.create!(name: "test")

    tags = JSON.parse(Tools::Tags.call.content.first[:text])

    assert_equal [ "test" ], tags.pluck("name")
  end
  end
end
