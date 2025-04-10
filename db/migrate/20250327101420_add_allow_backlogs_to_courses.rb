class AddAllowBacklogsToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :allow_backlogs, :integer, default: 0, null: false
  end
end
