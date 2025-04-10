class UniversityApplicationProcess < ApplicationRecord
  belongs_to :university

  validates :requirement, presence: true
end
