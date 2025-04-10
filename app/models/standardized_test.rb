class StandardizedTest < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :course_test_requirements, dependent: :destroy
  has_many :courses, through: :course_test_requirements

  enum :exam_type, {
    overall: 0,
    reading: 1,
    writing: 2,
    speaking: 3,
    listening: 4
  }, prefix: true

  validates :test_name, presence: true
  validates :exam_type, presence: true

  # Elasticsearch settings
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :test_name, type: 'text'
      indexes :exam_type, type: 'keyword'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
    end
  end

  # Custom search for Standardized Tests
  def self.search_tests(query, limit: 10)
    __elasticsearch__.search(
      query: {
        multi_match: {
          query: query,
          fields: %w[test_name exam_type]
        }
      },
      size: limit
    ).records
  end
end
