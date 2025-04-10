class CreateCourseTags < ActiveRecord::Migration[7.1]
  def change
    create_table :course_tags do |t|
      t.references :course, null: false, foreign_key: true, index: true
      t.references :tag, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
