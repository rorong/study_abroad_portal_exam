class Subject < ApplicationRecord
    belongs_to :academic_level
    belongs_to :education_board
    has_many :course_subject_requirements, dependent: :destroy
    has_many :courses, through: :course_subject_requirements
  
    validates :name, presence: true
    validates :academic_level_id, presence: true
    validates :education_board_id, presence: true
end
  