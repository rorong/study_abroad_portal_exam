class CreateUniversityApplicationProcesses < ActiveRecord::Migration[7.1]
  def change
    create_table :university_application_processes do |t|
      t.references :university, null: false, foreign_key: true
      t.string :requirement
      t.boolean :required

      t.timestamps
    end
  end
end
