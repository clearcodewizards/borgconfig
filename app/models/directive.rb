class Directive < ApplicationRecord
  belongs_to :cube
  belongs_to :depends_on, class_name: "Directive", optional: true

  enum :status, { pending: 0, in_progress: 1, completed: 2, error: 3 }

  validates :filename, presence: true
  validate :filename_exists

  def filename_exists
    errors.add(:filename, "should exist") unless CubeFile.all.key?(filename)
  end
end
