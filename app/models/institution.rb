class Institution < ApplicationRecord
    has_many :courses, dependent: :destroy
    # has_many :universities, dependent: :destroy, foreign_key: 'university_owner_id'
    # has_many :universities, foreign_key: 'university_owner_id', primary_key: 'record_id'
    # belongs_to :university, foreign_key: 'record_id', primary_key: 'record_id', optional: true
    has_many :universities, foreign_key: 'university_owner_id', primary_key: 'record_id'

    
    validates :name, presence: true, uniqueness: true
    
    # Scope for case-insensitive name search
    scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") if query.present? }
end
