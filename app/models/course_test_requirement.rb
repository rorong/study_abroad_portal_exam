class CourseTestRequirement < ApplicationRecord

    belongs_to :course
    belongs_to :standardized_test
end
