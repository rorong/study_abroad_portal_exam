class UniversityContact < ApplicationRecord
  belongs_to :university

  # Contact Information
  belongs_to :account_manager, class_name: 'User', optional: true
  belongs_to :international_manager, class_name: 'User', optional: true
  belongs_to :accounts_executive, class_name: 'User', optional: true

  validates :role, :name, presence: true
end
