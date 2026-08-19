class Directive < ApplicationRecord
  belongs_to :cube
  belongs_to :directive, optional: true

  enum :status, { pending: 0, in_progress: 1, completed: 2, error: 3 }

  validates :filename, presence: true
end
