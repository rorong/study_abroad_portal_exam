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
      t.datetime :sales_start_date
      t.datetime :sales_end_date
      t.datetime :support_start_date
      t.datetime :support_end_date
      t.string :created_by_id
      t.string :modified_by_id
      t.string :vendor_id
      t.string :manufacturer
      t.decimal :unit_price
      t.decimal :commission_rate
      t.decimal :tax
      t.string :usage_unit
      t.integer :qty_ordered
      t.integer :quantity_in_stock
      t.integer :reorder_level
      t.string :handler_id
      t.integer :quantity_in_demand
      t.text :description
      t.boolean :taxable
      t.string :currency
      t.decimal :exchange_rate
      t.string :layout_id
      t.string :tag
      t.string :image
      t.boolean :see_financial_docs_before_visa
      t.boolean :see_financial_docs_before_offer
      t.boolean :ask_deposit_before_visa
      t.boolean :ask_deposit_conditional_offer
      t.string :aec_account_manager
      t.string :application_process_type
      t.string :aec_account_manager_mobile
      t.string :aec_account_manager_email
      t.string :international_manager_phone
      t.date :contract_valid_till
      t.string :international_manager_name
      t.string :accounts_executive_name
      t.string :international_manager_email
      t.boolean :need_sop
      t.string :accounts_executive_phone
      t.string :accounts_executive_email
      t.boolean :interview_before_offer
      t.boolean :need_lor
      t.string :other_useful_contact
      t.integer :turnaround_time_days
      t.boolean :interview_before_visa
      t.boolean :accept_agent_appointment
      t.boolean :accept_agent_change
      t.string :processed_through
      t.datetime :user_modified_time
      t.datetime :system_activity_time
      t.datetime :user_activity_time
      t.datetime :system_modified_time
      t.integer :the_world_ranking
      t.integer :qs_world_ranking_latest
      t.integer :total_staff
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8         
      t.string :address_2
      t.text :scholarship_details
      t.text :notable_alumni
      t.text :affiliations
      t.text :misc_rankings
      t.integer :number_of_campuses
      t.decimal :campus_size_acres
      t.string :campus_location
      t.string :tier
      t.string :record_status
      t.boolean :locked

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
    add_index :universities, :vendor_id
    add_index :universities, :handler_id
    add_index :universities, :created_by_id
    add_index :universities, :modified_by_id
    add_index :universities, :layout_id
    add_index :universities, :tag
    add_index :universities, :aec_account_manager
    add_index :universities, :international_manager_name
    add_index :universities, :accounts_executive_name
    add_index :universities, :processed_through
    add_index :universities, :record_status
    add_index :universities, :locked
  end
end
