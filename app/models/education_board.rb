class EducationBoard < ApplicationRecord
    has_many :academic_levels, dependent: :destroy
    has_many :subjects, dependent: :destroy
    has_many :courses
    validates :board_name, presence: true, uniqueness: true
 end