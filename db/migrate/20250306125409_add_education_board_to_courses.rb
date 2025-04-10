class AddEducationBoardToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :education_board_id, :integer
  end
end
