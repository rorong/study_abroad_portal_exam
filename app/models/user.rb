require 'devise'

class User < ApplicationRecord
  acts_as_tenant(:agency)
  extend Devise::Models
  # Include default Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]

  self.primary_key = 'id'

  has_many :created_universities, class_name: "University", foreign_key: "created_by_id", primary_key: "record_id"
  has_many :modified_universities, class_name: "University", foreign_key: "modified_by_id", primary_key: "record_id"
  has_many :owned_universities, class_name: "University", foreign_key: "university_owner_id", primary_key: "record_id"
  # Normalize email before saving
  normalizes :email, with: ->(e) { e.strip.downcase }

  # Role-based authentication
  enum :role, student: "student", agency: "agency"

  # Set default role when a new record is initialized
  after_initialize :set_default_role, if: :new_record?

  def self.from_omniauth(auth)
    user_exists = User.find_by(email: auth.info.email)
    if user_exists
      user_exists.update(remember_created_at: Time.current)
      return user_exists
    end

    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.remember_created_at = Time.current
    end
  end

  private

  def set_default_role
    self.role ||= "student"  # Ensures default role is 'student'
  end
end
