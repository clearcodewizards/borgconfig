require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "authenticates with its password" do
    user = User.new(email_address: "person@example.com", password: "secret")

    assert user.authenticate("secret")
    assert_not user.authenticate("incorrect")
  end

  test "normalizes email addresses" do
    user = User.create!(email_address: "  PERSON@Example.COM ", password: "secret")

    assert_equal "person@example.com", user.email_address
  end

  test "generates a 64 character api token" do
    user = User.create!(email_address: "person@example.com", password: "secret")

    assert_equal 64, user.api_token.length
  end

  test "supports every role" do
    assert_equal %w[guest member editor manager admin], User.roles.keys
  end

  test "uses the name as the display name when present" do
    user = User.new(name: "Ada Lovelace", email_address: "ada@example.com")

    assert_equal "Ada Lovelace", user.display_name
  end

  test "derives the display name from the email when name is blank" do
    user = User.new(name: "", email_address: "ada_lovelace@example.com")

    assert_equal "Ada Lovelace", user.display_name
  end

  test "destroying a user destroys its sessions" do
    user = User.create!(email_address: "person@example.com", password: "secret")
    session = user.sessions.create!

    user.destroy!

    assert_not Session.exists?(session.id)
  end
end
