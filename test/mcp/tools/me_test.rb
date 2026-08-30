require "test_helper"

module Tools
  class MeTest < ActiveSupport::TestCase
  test "serializes the current user" do
    admin = users(:one)
    admin.update!(role: :admin)

    user = JSON.parse(Tools::Me.call(server_context: { user_id: admin.id }).content.first[:text])

    assert_equal admin.id, user.fetch("id")
    assert_equal "admin", user.fetch("role")
  end
  end
end
