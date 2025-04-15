class CreateAgencies < ActiveRecord::Migration[7.1]
  def change
    create_table :agencies do |t|
      t.string :name
      t.string :subdomain, null: false

      t.timestamps
    end

    add_index :agencies, :subdomain, unique: true
  end
end
