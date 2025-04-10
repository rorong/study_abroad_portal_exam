class CourseSubjectRequirement < ApplicationRecord
  belongs_to :course
  belongs_to :subject

  validates :course_id, :subject_id, presence: true
end
