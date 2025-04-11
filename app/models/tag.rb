class Tag < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ElasticsearchIndexing
  
  has_many :course_tags, dependent: :destroy
  has_many :courses, through: :course_tags

   # Custom JSON for Elasticsearch indexing
  def as_indexed_json(options = {})
    self.as_json(
      only: [:id, :tag_name]
    ).compact
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
      indexes :tag_name, type: 'keyword'
    end
  end
end
