class AddAllowBacklogsToCourseRequirements < ActiveRecord::Migration[7.1]
  def change
    add_column :course_requirements, :allow_backlogs, :integer
  end
end
