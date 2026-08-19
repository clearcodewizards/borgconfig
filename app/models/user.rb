class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_token, length: 64
  encrypts :api_token, deterministic: true

  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { guest: 0, member: 1, editor: 2, manager: 3, admin: 4 }

  def display_name
    return name if name.present?

    email_address.split("@").first.titleize
  end
end
