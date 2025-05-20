class RemoveUnusedFieldsFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :email_address, :string
    remove_column :users, :secondary_email, :string
    remove_column :users, :password_digest, :string
  end
end
