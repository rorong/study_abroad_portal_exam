class Department < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    include ElasticsearchIndexing

    has_many :courses, dependent: :destroy
    has_many :subjects 

    # Custom JSON for Elasticsearch indexing
    def as_indexed_json(options = {})
      self.as_json(
        only: [:id, :name]
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
        indexes :id, type: 'keyword'
        indexes :name, analyzer: 'autocomplete'
      end
    end
end
