class AcademicLevel < ApplicationRecord
  belongs_to :education_board
  has_many :subjects, dependent: :destroy
  
  # validates :level_name, presence: true
  # validates :education_board_id, presence: true
end
