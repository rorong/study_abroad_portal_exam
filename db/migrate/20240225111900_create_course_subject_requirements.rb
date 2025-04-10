class CreateCourseSubjectRequirements < ActiveRecord::Migration[7.1]
  def change
    create_table :course_subject_requirements do |t|
      t.references :course, foreign_key: true, index: true
      t.references :subject, foreign_key: true, index: true
      t.float :min_score
      t.timestamps
    end
  end
end
