require "test_helper"

module Tools
  class TagsTest < ActiveSupport::TestCase
  test "serializes tag names" do
    Tag.create!(name: "test")

    user = users(:one)
    user.update!(role: :member)
    tags = JSON.parse(Tools::Tags.call(server_context: { user_id: user.id }).content.first[:text])

    assert_equal [ "test" ], tags.pluck("name")
  end
  end
end
