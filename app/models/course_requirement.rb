class CourseRequirement < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ElasticsearchIndexing

  belongs_to :course
  
  # validates :course_id, presence: true
  
  # Add any additional validations as needed

  # Custom JSON for Elasticsearch indexing
  def as_indexed_json(options = {})
    self.as_json(
      only: [:id, :lateral_entry_possible]
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
      indexes :id, analyzer: 'keyword'
      indexes :lateral_entry_possible, type: 'boolean'
    end
  end

end 