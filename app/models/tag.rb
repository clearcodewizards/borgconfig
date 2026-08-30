class Tag < ApplicationRecord
  has_many :cube_tags, dependent: :destroy
  has_many :cubes, through: :cube_tags

  validates :name, uniqueness: true
end
