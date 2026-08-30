class Cube < ApplicationRecord
  has_many :directives, dependent: :destroy
  has_many :cube_tags, dependent: :destroy
  has_many :tags, through: :cube_tags

  encrypts :api_token, deterministic: true

  enum :status, { pending: 0, in_progress: 1, completed: 2 }

  validates :api_token, uniqueness: true

  scope :tagged_with, lambda { |name|
    joins(:tags).where(tags: { name: name })
  }
end
