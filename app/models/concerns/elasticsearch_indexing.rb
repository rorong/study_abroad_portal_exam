module ElasticsearchIndexing
  extend ActiveSupport::Concern

  class_methods do
    def reindex_all
      index_name = self.__elasticsearch__.index_name

      if __elasticsearch__.client.indices.exists? index: index_name
        __elasticsearch__.client.indices.delete index: index_name
        Rails.logger.info "✅ Deleted existing '#{index_name}' index."
      end

      __elasticsearch__.create_index! force: true
      Rails.logger.info "✅ Created '#{index_name}' index with mappings."

      import
      Rails.logger.info "✅ Reindexed #{name} data into '#{index_name}'."
    end
  end
end
