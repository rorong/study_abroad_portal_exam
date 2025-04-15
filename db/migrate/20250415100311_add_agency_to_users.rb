class AddAgencyToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :agency, null: true, foreign_key: true
  end
end
