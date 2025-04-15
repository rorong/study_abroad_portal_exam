class AddAgencyToCourses < ActiveRecord::Migration[7.1]
  def change
    add_reference :courses, :agency, null: true, foreign_key: true
  end
end
