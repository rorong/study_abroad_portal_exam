class CreateCourseUniversities < ActiveRecord::Migration[7.1]
  def change
    create_table :course_universities do |t|
      t.references :course, null: false, foreign_key: true
      t.references :university, null: false, foreign_key: true

      t.timestamps
    end
  end
end
