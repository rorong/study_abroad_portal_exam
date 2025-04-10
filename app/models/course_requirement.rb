class CourseRequirement < ApplicationRecord
  belongs_to :course
  
  # validates :course_id, presence: true
  
  # Add any additional validations as needed
end 