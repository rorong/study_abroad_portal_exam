class CreateRemarks < ActiveRecord::Migration[7.1]
  def change
    create_table :remarks do |t|
      t.references :user, null: false, foreign_key: true, index: true  # ✅ Corrected
      t.references :course, null: false, foreign_key: true, index: true
      t.text :remarks_course_desc
      t.text :remarks_selt
      t.text :remarks_entry_req

      t.timestamps
    end
  end
end
