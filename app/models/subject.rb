class Subject < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    belongs_to :academic_level
    belongs_to :education_board
    has_many :course_subject_requirements, dependent: :destroy
    has_many :courses, through: :course_subject_requirements
  
    validates :name, presence: true
    validates :academic_level_id, presence: true
    validates :education_board_id, presence: true
  
    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :name, type: 'text'
        indexes :created_at, type: 'date'
        indexes :updated_at, type: 'date'
      end
    end
  
    def self.search_subjects(query, limit: 10)
      __elasticsearch__.search(
        query: {
          multi_match: {
            query: query,
            fields: %w[name]
          }
        },
        size: limit
      ).records
    end
  end
  