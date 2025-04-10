class CreateUniversities < ActiveRecord::Migration[7.1]
  def change
    create_table :universities do |t|
      t.string :record_id
      t.string :university_owner_id
      t.string :name
      t.string :code
      t.boolean :active
      t.string :category
      t.string :city
      t.string :address
      t.string :country
      t.string :state
      t.string :switchboard_no
      t.string :post_code
      t.string :website
      t.integer :world_ranking
      t.integer :qs_ranking
      t.integer :national_ranking
      t.integer :established_in
      t.integer :total_students
      t.integer :total_international_students
      t.string :type_of_university
      t.decimal :application_fee
      t.boolean :conditional_offers
      t.boolean :lateral_entry_allowed
      t.boolean :on_campus_accommodation

      t.timestamps
    end

    add_index :universities, :record_id
    add_index :universities, :code
    add_index :universities, :name
    add_index :universities, :country
    add_index :universities, :university_owner_id
    add_index :universities, :state
    add_index :universities, :city
    add_index :universities, :active
  end
end
