class CreateUniversityContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :university_contacts do |t|
      t.references :university, null: false, foreign_key: true
      t.string :role
      t.string :name
      t.string :email
      t.string :phone

      t.timestamps
    end

    add_index :university_contacts, :email
    add_index :university_contacts, :role
    add_index :university_contacts, :name
  end
end
