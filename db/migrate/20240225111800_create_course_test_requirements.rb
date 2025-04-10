class CreateCourseTestRequirements < ActiveRecord::Migration[7.0]
  def change
    create_table :course_test_requirements do |t|
      t.references :course, foreign_key: true, index: true
      t.references :standardized_test, foreign_key: true, index: true
      t.float :min_score
      t.timestamps
    end
  end
end
