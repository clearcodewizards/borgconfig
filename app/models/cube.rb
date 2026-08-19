class Cube < ApplicationRecord
  has_many :directives, dependent: :destroy

  encrypts :api_token, deterministic: true

  enum :status, { pending: 0, in_progress: 1, completed: 2 }

  validates :api_token, uniqueness: true
end
