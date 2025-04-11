class University < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    include ElasticsearchIndexing

    has_many :course_universities, dependent: :destroy
    has_many :courses, through: :course_universities

    # Associations with User (for created_by, modified_by, etc.)
    belongs_to :owner, class_name: "User", primary_key: "record_id", foreign_key: "university_owner_id", optional: true
    belongs_to :creator, class_name: "User", primary_key: "record_id", foreign_key: "created_by_id", optional: true
    belongs_to :modifier, class_name: "User", primary_key: "record_id", foreign_key: "modified_by_id", optional: true
    validates :record_id, :name, presence: true


    # Custom JSON for Elasticsearch indexing
    def as_indexed_json(options = {})
      self.as_json(
        only: [:id, :name, :code, :category, :city, :address,
         :country, :state, :post_code, :world_ranking, :qs_ranking, :national_ranking,
          :application_fee, :lateral_entry_allowed, :latitude, :longitude, :type_of_university]
      )
    end

    settings index: {
      number_of_shards: 1,
      analysis: {
        filter: {
          autocomplete_filter: {
            type:     'edge_ngram',
            min_gram: 1,
            max_gram: 20
          }
        },
        analyzer: {
          autocomplete: {
            type:      'custom',
            tokenizer: 'standard',
            filter:    ['lowercase', 'autocomplete_filter']
          }
        }
      }
    } do
      mappings dynamic: false do
        indexes :name, analyzer: 'autocomplete'
        indexes :code, analyzer: 'autocomplete'

        # Fields for exact matching (should use keyword)
        indexes :city, type: 'keyword'
        indexes :country, type: 'keyword'
        indexes :state, type: 'keyword'
        indexes :post_code, type: 'keyword'
        indexes :type_of_university, type: 'keyword'

        # Text fields for full-text search (without autocomplete)
        indexes :address, type: 'text'
        indexes :world_ranking, type: 'text'
        indexes :qs_ranking, type: 'text'
        indexes :national_ranking, type: 'text'

        # Numeric fields (latitude, longitude, fees, rankings)
        indexes :application_fee, type: 'float'
        indexes :latitude, type: 'float'
        indexes :longitude, type: 'float'
      end
    end
  end
  