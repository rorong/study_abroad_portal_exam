class CourseUniversity < ApplicationRecord
  belongs_to :course
  belongs_to :university

  validates :course_id, :university_id, presence: true
end
