class Course < ApplicationRecord
  # acts_as_tenant(:agency)

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ElasticsearchIndexing
  
  has_many :course_universities, dependent: :destroy
  has_many :universities, through: :course_universities

  # Relationships
  belongs_to :owner, class_name: 'User'
  belongs_to :creator, class_name: 'User'
  belongs_to :modifier, class_name: 'User'
  belongs_to :department

  has_one :course_requirement, dependent: :destroy
  has_many :remarks, dependent: :destroy
  has_many :course_tags, dependent: :destroy
  has_many :tags, through: :course_tags

  belongs_to :university, class_name: "University", primary_key: "record_id", foreign_key: "university_id", optional: true

  # belongs_to :education_board, optional: true
  # has_many :course_test_requirements, dependent: :destroy
  # has_many :standardized_tests, through: :course_test_requirements
  # has_many :course_subject_requirements, dependent: :destroy
  # has_many :subjects, through: :course_subject_requirements

  # Validations
  validates :name, :title, :course_code, presence: true
  validates :duration_months, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :tuition_fee_international, :tuition_fee_local, :application_fee,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(should_delete: false) }
  scope :available_for_international, -> { where(international_students_eligible: true) }
  scope :unlocked, -> { where(locked: false) }

  # Custom JSON for Elasticsearch indexing
  def as_indexed_json(options = {})
    self.as_json(
      only: [:id, :record_id, :name, :level_of_course, 
            :course_code, :course_duration, :title, :application_fee,
            :tuition_fee_international, :tuition_fee_local, :intake,
            :delivery_method, :internship_period, :duration_months,
            :international_students_eligible, :module_subjects, :allow_backlogs, :department_id, :current_status, :course_module],
      include: {
        universities: { only: [:id, :record_id, :name, :code, :category, :city, :address,
         :country, :state, :post_code, :world_ranking, :qs_ranking, :national_ranking,
          :application_fee, :lateral_entry_allowed, :latitude, :longitude, :type_of_university],
          methods: [:location]  # 👉 This is the key fix 
        },
        tags: { only: [:id, :tag_name] },
        department: { only: [:id, :name] },
        course_requirement: { only: [:id, :lateral_entry_possible] }
      }
    )
  end

  settings index: {
    number_of_shards: 1,
    analysis: {
      filter: {
        autocomplete_filter: {
          type:     'edge_ngram',
          min_gram: 2,
          max_gram: 20
        },
        synonym_filter: {
          type: 'synonym',
          synonyms: [
            # 🎓 Business & MBA
            "mba => business, business management, business/management, business analytics, marketing, accounting, finance, human resources, master of business administration",
            "business => mba, business management, business/management, business analytics, marketing, accounting, finance, human resources, entrepreneurship",
            "management => mba, business management, business/management, human resources",
            "business/management => mba, management, business, business analytics, marketing, accounting, finance, hr",
            "business management => business, mba, entrepreneurship, marketing, hr",
            "business analytics => mba, analytics, data analytics, data science",
            "finance => accounting, business, business management, economics, mba",
            "accounting => finance, business, mba",
            "human resources => hr, mba, business management",
            "marketing => business, mba, digital marketing, business analytics",
            "bba => BBA, Bachelor of Business Administration, BBA Specialization in Accounting, BBA Specialization in Energy Management, BBA Specialization in Project Management, Business Management, Business Analytics, Marketing, Accounting, Finance, HR, Human Resources",

            # 🛠️ Engineering
            "engineering => chemical engineering, civil engineering, mechanical engineering, electrical engineering, aerospace engineering, computer science, software engineering, information technology, material science, robotics, mechatronics, environmental engineering",
            "mechanical engineering => robotics, mechatronics",
            "electrical engineering => electronics, electrical engineering",
            "computer science => software engineering, cs, it, information technology, programming, ai, artificial intelligence",
            "information technology => computer science, software engineering, it, cloud computing",
            "aerospace engineering => aviation, space science",
            "civil engineering => architecture, construction",
            "architecture => civil engineering, built environment",
            "chemical engineering => chemistry, industrial chemistry",
            "material science => metallurgy, physics, nanotechnology",
            "mechatronics => robotics, automation",
            "software engineering => computer science, programming",

            # 🔬 Science
            "science => biology, chemistry, physics, mathematics, environmental science, health sciences, life sciences, medicine, pharmacy",
            "life sciences => biology, health sciences, medicine",
            "health sciences => nursing, physiotherapy, pharmacy",
            "medicine => health sciences, pharmacy",
            "pharmacy => medicine, chemistry, biology",
            "physics => astronomy, astrophysics",
            "mathematics => statistics, data science, analytics",
            "statistics => mathematics, data science",
            "biology => biological sciences, medicine",
            "environment and sustainability => environmental science, ecology",
            "chemistry => chemical sciences, biology",

            # 👨‍🎓 Humanities & Social Sciences
            "humanities => social sciences, literature, history, culture",
            "social sciences => sociology, psychology, criminology, economics",
            "psychology => behavioral sciences, mental health, neuroscience",
            "law => legal studies, business law, corporate law",
            "education => teaching, pedagogy",
            "economics => finance, business, econometrics",
            "history => culture, literature",
            "language => literature, linguistics",
            "literature language and culture => language, literature, humanities",

            # 🎨 Creative Arts & Media
            "art and design => fine arts, graphic design, visual arts, fashion",
            "music => performing arts, audio production",
            "dance => performing arts, choreography",
            "film making => media studies, film production, photography",
            "journalism and media studies => film making, communication",
            "performance arts => music, dance, theatre",
            "photography => film making, visual media",

            # 🧑‍🍳 Other Specialized
            "culinary => food sciences, hospitality, cooking, gastronomy",
            "hospitality => tourism, hotel management, event management",
            "sports sciences => physiotherapy, fitness, health sciences",
            "physiotherapy => health sciences, rehabilitation",
            "zoology => biology, life sciences",
            "agriculture => food sciences, environmental science",
            "archeology => history, culture",
            "textiles => fashion, fabric design"

          ]
        }
      },
      analyzer: {
        autocomplete: {
          type:      'custom',
          tokenizer: 'standard',
          filter:    ['lowercase', 'synonym_filter', 'autocomplete_filter']
        },
        autocomplete_search: {
          type: 'custom',
          tokenizer: 'standard',
          filter: ['lowercase', 'synonym_filter']
        },
        synonym_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: ['lowercase', 'synonym_filter']
        }
      }
    }
  } do
    mappings dynamic: false do
      indexes :name, type: 'text', analyzer: 'autocomplete', search_analyzer: 'autocomplete_search'
      indexes :title, analyzer: 'autocomplete'

      # Fields for exact matching (should use keyword)
      indexes :id, type: 'keyword'
      indexes :record_id, type: 'keyword'
      indexes :course_code, type: 'keyword'
      indexes :level_of_course, type: 'keyword'
      indexes :delivery_method, type: 'keyword'
      indexes :current_status, type: 'keyword'
      indexes :department_id, type: 'keyword'
      indexes :intake, type: 'keyword'
      indexes :course_duration, type: 'float'
      indexes :internship_period, type: 'float'

      # Text fields for full-text search (without autocomplete)
      indexes :module_subjects, type: 'text'

      indexes :course_module, type: 'text'
      indexes :ml, type: 'object' do
        indexes :tokens, type: 'rank_features'
      end

      # float 
      indexes :tuition_fee_international, type: 'float'
      indexes :application_fee, type: 'float'
      indexes :allow_backlogs, type: 'float'

      indexes :universities, type: 'nested' do
        indexes :id, type: 'keyword'
        indexes :record_id, type: 'keyword'
        indexes :world_ranking, type: 'integer'
        indexes :qs_ranking, type: 'integer'
        indexes :national_ranking, type: 'integer'
        indexes :name, analyzer: 'autocomplete'
        indexes :type_of_university, type: 'keyword'
        indexes :country, type: 'text' do
        indexes :raw, type: 'keyword'
        end

       indexes :address, type: 'text', analyzer: 'autocomplete', search_analyzer: 'standard'
       
       # Add geo_point for location field (latitude and longitude)
       indexes :location, type: 'geo_point'
      end

      indexes :tags, type: 'nested' do
        indexes :id, type: 'keyword'
        indexes :tag_name, type: 'keyword'
      end

      indexes :department, type: 'nested' do
        indexes :id, type: 'keyword'
        indexes :name, type: 'text', analyzer: 'synonym_analyzer', search_analyzer: 'synonym_analyzer', fields: {
          autocomplete: {
            type: 'text',
            analyzer: 'autocomplete',
            search_analyzer: 'autocomplete_search'
          }
        }
      end

      indexes :course_requirement, type: 'nested' do
        indexes :id, type: 'keyword'
        indexes :lateral_entry_possible, type: 'boolean'
      end

    end
  end
  
  def self.advanced_search(query, filters = {}, sort=nil, page=1, per_page=15)
    from = (page - 1) * per_page

    search_definition = {
      from: from,
      size: per_page,
      min_score: 1.2,
      track_total_hits: true,  # 👈 This ensures it calculates the full total
      query: {
        bool: {
          must: [],
          filter: []
        }
      },
      aggs: {
        course_requirement: {
          nested: {
            path: "course_requirement"
          },
          aggs: {
            lateral_entry_possible: {
              terms: {
                field: "course_requirement.lateral_entry_possible",
                size: 2
              }
            }
          }
        },
        tags: {
          nested: {
            path: "tags"
          },
          aggs: {
            by_tag: {
              terms: {
                field: "tags.id",  # Field for the tag id
                size: 10000  # Adjust the size if you expect a larger number of tags
              }
            }
          }
        },
        unique_courses: {
          terms: {
            field: "id",
            size: 10000  # Adjust size as needed to cover all possible course IDs
          }
        },
        unique_universities: {
          nested: {
            path: "universities"
          },
          aggs: {
            ids: {
              terms: {
                field: "universities.id",
                size: 10000,
                shard_size: 50000  # a bit higher than size, to be safe
              }
            },
            by_country: {
              terms: {
                field: "universities.country.raw", # assuming keyword mapping
                size: 10000,
                shard_size: 50000  # a bit higher than size, to be safe
              }
            },
            by_type_of_university: {
              terms: {
                field: "universities.type_of_university", # assuming keyword mapping
                size: 10000,
                shard_size: 50000  # a bit higher than size, to be safe
              }
            },
            min_world_ranking: {
              min: {
                field: "universities.world_ranking"
              }
            },
            max_world_ranking: {
              max: {
                field: "universities.world_ranking"
              }
            },
            min_national_ranking: {
              min: {
                field: "universities.national_ranking"
              }
            },
            max_national_ranking: {
              max: {
                field: "universities.national_ranking"
              }
            },
            min_qs_ranking: {
              min: {
                field: "universities.national_ranking"
              }
            },
            max_qs_ranking: {
              max: {
                field: "universities.national_ranking"
              }
            }
          }
        },
        unique_departments: {
          nested: {
            path: "department"
          },
          aggs: {
            ids: {
              terms: {
                field: "department.id",
                size: 10000,
                shard_size: 50000  # a bit higher than size, to be safe
              }
            }
          }
        },
        by_intake: {
          terms: {
            field: "intake",
            size: 10000,
            shard_size: 50000  # a bit higher than size, to be safe
          }
        },
        by_current_status: {
          terms: {
            field: "current_status",
            size: 10000,
            shard_size: 50000  # a bit higher than size, to be safe
          }
        },
        by_delivery_method: {
          terms: {
            field: "delivery_method",
            size: 10000,
            shard_size: 50000  # a bit higher than size, to be safe
          }
        },
        by_level_of_course: {
          terms: {
            field: "level_of_course",
            size: 10000,
            shard_size: 50000  # a bit higher than size, to be safe
          }
        },
        by_allow_backlogs: {
          terms: {
            field: "allow_backlogs",
            size: 10000,
            shard_size: 50000  # a bit higher than size, to be safe
          }
        },
        min_application_fee: {
          min: {
            field: "application_fee"  # Adjust the field name if necessary
          }
        },
        max_application_fee: {
          max: {
            field: "application_fee"  # Adjust the field name if necessary
          }
        },
        min_tution_fee: {
          min: {
            field: "tuition_fee_international"  # Adjust the field name if necessary
          }
        },
        max_tution_fee: {
          max: {
            field: "tuition_fee_international"  # Adjust the field name if necessary
          }
        },
        min_duration: {
          min: {
           field: "course_duration"
          }
        },
        max_duration: {
          max: {
            field: "course_duration"
          }
        },
        min_internship: {
          min: {
           field: "internship_period"
          }
        },
        max_internship: {
          max: {
            field: "internship_period"
          }
        }
      }

    }

    # Full-text semantic search using ELSER

    if query.present?
      search_definition[:query][:bool][:must] << {
        text_expansion: {
          "ml.tokens": {
            model_id: ".elser_model_2_linux-x86_64",
            model_text: query
          }
        }
      }
    else
      search_definition[:query][:bool][:must] << { match_all: {} }
    end


    # Filters
    if filters[:min_tuition_fee].present? || filters[:max_tuition_fee].present?
      filters[:min_tuition_fee] ||= 0
      filters[:max_tuition_fee] ||= Float::INFINITY
      search_definition[:query][:bool][:filter] << {
          range: { tuition_fee_international: { gte: filters[:min_tuition_fee], lte: filters[:max_tuition_fee] } }
        }
    end

    #looking on it 
    if filters[:min_duration].present? || filters[:max_duration].present?
      min_duration = filters[:min_duration].present? ? filters[:min_duration].to_i : 0
      max_duration = filters[:max_duration].present? ? filters[:max_duration].to_i : Float::INFINITY

      search_definition[:query][:bool][:filter] << {
          range: { course_duration: { gte: min_duration, lte: max_duration } }
        }
    end

    #looking on it 
    if filters[:min_internship].present? || filters[:max_internship].present?
      min_internship = filters[:min_internship].present? ? filters[:min_internship].to_i : 0
      max_internship = filters[:max_internship].present? ? filters[:max_internship].to_i : Float::INFINITY

      search_definition[:query][:bool][:filter] << {
          range: { internship_period: { gte: min_internship, lte: max_internship } }
        }
    end

    if filters[:min_application_fee].present? || filters[:max_application_fee].present?
      min_application_fee = filters[:min_application_fee].present? ? filters[:min_application_fee].to_i : 0
      max_application_fee = filters[:max_application_fee].present? ? filters[:max_application_fee].to_i : Float::INFINITY

      search_definition[:query][:bool][:filter] << {
          range: { application_fee: { gte: min_application_fee, lte: max_application_fee } }
        }
    end

    if filters[:tag_id].present?
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: 'tags',
          query: {
            terms: { 'tags.id': filters[:tag_id] }
          }
        }
      }
    end
    

    if filters[:intake].present?
      search_definition[:query][:bool][:filter] << {
        term: { intake: filters[:intake] }
      }
    end

    if filters[:allow_backlogs].present?
      search_definition[:query][:bool][:filter] << {
        term: { allow_backlogs: filters[:allow_backlogs] }
      }
    end

    if filters[:current_status].present?
      search_definition[:query][:bool][:filter] << {
        term: { current_status: filters[:current_status] }
      }
    end

    if filters[:delivery_method].present?
      search_definition[:query][:bool][:filter] << {
        term: { delivery_method: filters[:delivery_method] }
      }
    end

    if filters[:level_of_course].present?
      search_definition[:query][:bool][:filter] << {
        term: { level_of_course: filters[:level_of_course] }
      }
    end

    if filters[:department_id].present?
       # Use a nested query for department.name
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: "department",
          query: {
            term: { "department.id": filters[:department_id] }
          }
        }
      }
    end

    if filters[:lateral_entry_possible].present?
       # Use a nested query for department.name
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: "course_requirement",
          query: {
            term: { "course_requirement.lateral_entry_possible": filters[:lateral_entry_possible] }
          }
        }
      }
    end

    # #TEST
    if filters[:type_of_university].present?
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: "universities",
          query: {
            term: { "universities.type_of_university": filters[:type_of_university] }
          }
        }
      }
    end

    if filters[:university_id].present?
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: "universities",
          query: {
            term: { "universities.id": filters[:university_id] }
          }
        }
      }
    end

    if filters[:university_country].present?
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: "universities",
          query: {
            term: { "universities.country.raw": filters[:university_country] }
          }
        }
      }
    end

    if filters[:university_address].present? && filters[:latitude].present? && filters[:longitude].present? && filters[:distance].present?
      
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: "universities",
          query: {
            bool: {
              filter: [
                {
                  geo_distance: {
                    distance: "#{filters[:distance]}km",
                    "universities.location": {
                      lat: filters[:latitude].to_f,
                      lon: filters[:longitude].to_f
                    }
                  }
                }
              ]
            }
          }
        }
      }
    end

    if filters[:min_world_ranking].present? || filters[:max_world_ranking].present?
      min_world_ranking = filters[:min_world_ranking].present? ? filters[:min_world_ranking].to_i : 0
      max_world_ranking = filters[:max_world_ranking].present? ? filters[:max_world_ranking].to_i : Float::INFINITY

      search_definition[:query][:bool][:filter] << {
          nested: {
            path: "universities",
            query: {
              range: {
                "universities.world_ranking": {
                  gte: min_world_ranking,
                  lte: max_world_ranking
                }.compact # removes nils if one of them is missing
              }
            }
          }
        }
    end

    if filters[:min_qs_ranking].present? || filters[:max_qs_ranking].present?
      min_qs_ranking = filters[:min_qs_ranking].present? ? filters[:min_qs_ranking].to_i : 0
      max_qs_ranking = filters[:max_qs_ranking].present? ? filters[:max_qs_ranking].to_i : Float::INFINITY

      search_definition[:query][:bool][:filter] << {
          nested: {
            path: "universities",
            query: {
              range: {
                "universities.qs_ranking": {
                  gte: min_qs_ranking,
                  lte: max_qs_ranking
                }.compact # removes nils if one of them is missing
              }
            }
          }
        }
    end

    if filters[:min_national_ranking].present? || filters[:max_national_ranking].present?
      min_national_ranking = filters[:min_national_ranking].present? ? filters[:min_national_ranking].to_i : 0
      max_national_ranking = filters[:max_national_ranking].present? ? filters[:max_national_ranking].to_i : Float::INFINITY

      search_definition[:query][:bool][:filter] << {
          nested: {
            path: "universities",
            query: {
              range: {
                "universities.national_ranking": {
                  gte: min_national_ranking,
                  lte: max_national_ranking
                }.compact # removes nils if one of them is missing
              }
            }
          }
        }
    end

    # # Sorting 
    case sort
      when 'application_fee_asc'
        search_definition[:sort] = [{ application_fee: { order: 'asc', missing: '_last' } }]
      when 'application_fee_desc'
        search_definition[:sort] = [{ application_fee: { order: 'desc', missing: '_last' } }]
      when 'tuition_fee_asc'
        search_definition[:sort] = [{ tuition_fee_international: { order: 'asc', missing: '_last' } }]
      when 'tuition_fee_desc'
        search_definition[:sort] = [{ tuition_fee_international: { order: 'desc', missing: '_last' } }]
      when 'course_duration_asc'
        search_definition[:sort] = [{ course_duration: { order: 'asc', missing: '_last' } }]
      when 'course_duration_desc'
        search_definition[:sort] = [{ course_duration: { order: 'desc', missing: '_last' } }]
    end
      __elasticsearch__.search(search_definition)
  end

end