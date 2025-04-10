class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :record_id
      t.string :name
      t.references :owner, null: false, foreign_key: { to_table: :users }, index: true  # ✅ Corrected
      t.references :creator, null: false, foreign_key: { to_table: :users }, index: true  # ✅ Corrected
      t.references :modifier, null: false, foreign_key: { to_table: :users }, index: true  # ✅ Corrected
      t.references :institution, null: false, foreign_key: true, index: true  # ✅ Corrected
      t.references :department, foreign_key: true, index: true

      t.datetime :last_activity_time
      t.string :layout_id
      t.datetime :user_modified_time
      t.datetime :system_modified_time
      t.datetime :user_related_activity_time
      t.datetime :system_related_activity_time
      t.string :record_approval_status
      t.boolean :is_record_duplicate
      t.string :course_image
      t.string :course_weblink
      t.string :level_of_course
      t.string :course_code
      t.string :course_duration
      t.string :title
      t.float :application_fee
      t.float :tuition_fee_international
      t.float :tuition_fee_local
      t.string :intake
      t.string :delivery_method
      t.string :internship_period
      t.string :record_status
      t.string :current_status
      t.boolean :locked, default: false
      t.boolean :delete_record, default: false
      t.integer :duration_months
      t.boolean :international_students_eligible
      t.boolean :should_delete, default: false
      t.text :module_subjects

      t.timestamps
    end

    add_index :courses, :course_code
    add_index :courses, :name
  end
end
