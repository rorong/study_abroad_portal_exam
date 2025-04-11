class CreateSubjects < ActiveRecord::Migration[7.1]
  def change
    create_table :subjects do |t|
      t.string :name
      t.references :academic_level, foreign_key: true, index: true
      t.references :education_board, foreign_key: true, index: true
      t.timestamps
    end
  end
end
