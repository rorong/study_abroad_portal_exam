class CreateStandardizedTests < ActiveRecord::Migration[7.1]
  def change
    create_table :standardized_tests do |t|
      t.string :test_name
      t.integer :exam_type
      t.timestamps
    end
  end
end
