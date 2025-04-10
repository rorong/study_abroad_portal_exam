class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t| # Remove default integer primary key
      t.string :record_id, index: true
      t.string :email_address
      t.string :secondary_email
      t.string :password_digest
      t.boolean :email_opt_out, default: false
      t.timestamps
    end

    add_index :users, :email_address
  end
end
