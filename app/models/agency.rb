class Agency < ApplicationRecord
	validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true

  has_many :users
  has_many :courses
end
