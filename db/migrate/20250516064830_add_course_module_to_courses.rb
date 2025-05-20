class AddCourseModuleToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :course_module, :text
  end
end
