class UniversityRanking < ApplicationRecord
  belongs_to :university

  validates :ranking_type, :ranking, presence: true
end
