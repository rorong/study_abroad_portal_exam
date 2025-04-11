class StandardizedTest < ApplicationRecord
  has_many :course_test_requirements, dependent: :destroy
  has_many :courses, through: :course_test_requirements

  enum :exam_type, {
    overall: 0,
    reading: 1,
    writing: 2,
    speaking: 3,
    listening: 4
  }, prefix: true

  validates :test_name, presence: true
  validates :exam_type, presence: true
end
