class Course < ApplicationRecord
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
  validates :name, :title, :course_code, :code, presence: true
  validates :code, uniqueness: true
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
            :international_students_eligible, :module_subjects, :allow_backlogs, :department_id, :current_status],
      include: {
        universities: { only: [:id, :record_id, :name, :code, :category, :city, :address,
         :country, :state, :post_code, :world_ranking, :qs_ranking, :national_ranking,
          :application_fee, :lateral_entry_allowed, :latitude, :longitude, :type_of_university] },
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
      indexes :course_duration, type: 'keyword'
      indexes :internship_period, type: 'keyword'

      # Text fields for full-text search (without autocomplete)
      indexes :module_subjects, type: 'text'

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
        indexes :tag_name, analyzer: 'autocomplete'
      end

      indexes :department, type: 'nested' do
        indexes :id, type: 'keyword'
        indexes :name, analyzer: 'autocomplete'
      end

      indexes :course_requirement, type: 'nested' do
        indexes :id, type: 'keyword'
        indexes :lateral_entry_possible, type: 'boolean'
      end

    end
  end

  def self.advanced_search(query, filters = {}, sort=nil)
    search_definition = {
      query: {
        bool: {
          must: [],
          filter: []
        }
      }
    }

    # Full-text search
    if query.present?
      search_definition[:query][:bool][:must] << {
        multi_match: {
          query: query,
          fields: ['name^3', 'title', 'course_code', 'module_subjects', 'universities.name', 'universities.country']
        }
      }
    end

    # Filters
    if filters[:min_tuition_fee].present? || filters[:max_tuition_fee].present?
      filters[:min_tuition_fee] ||= 0
      filters[:max_tuition_fee] ||= Float::INFINITY
      search_definition[:query][:bool][:filter] << {
          range: { tuition_fee_international: { gte: filters[:min_tuition_fee], lte: filters[:max_tuition_fee] } }
        }
    end

    if filters[:min_duration].present? || filters[:max_duration].present?
      min_duration = filters[:min_duration].present? ? filters[:min_duration].to_i : 0
      max_duration = filters[:max_duration].present? ? filters[:max_duration].to_i : Float::INFINITY

      search_definition[:query][:bool][:filter] << {
          range: { course_duration: { gte: min_duration, lte: max_duration } }
        }
    end

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
            terms: { 'tags.id': filters[:tag_ids] }
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

    if filters[:department_name].present?
       # Use a nested query for department.name
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: "department",
          query: {
            term: { "department.name": filters[:department_name] }
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

    #TEST
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

    if filters[:university_address].present?
      search_definition[:query][:bool][:filter] << {
        nested: {
          path: "universities",
          query: {
            match: {
              "universities.address": filters[:university_address]
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


    if filters[:latitude].present? && filters[:longitude].present?
      lat = filters[:latitude].to_f
      lng = filters[:longitude].to_f
      distance = filters[:distance].present? ? filters[:distance].to_f : 50 # Default to 50 km if not provided

      # Apply the geo_distance filter
      search_definition[:query][:bool][:filter] << {
        geo_distance: {
          distance: "#{distance}km",  # Distance filter in km (you can change this to "mi" for miles, etc.)
          "universities.location": { lat: lat, lon: lng }
        }
      }
    end

    # Sorting 
    case sort
      when 'application_fee_asc'
        search_definition[:sort] = [{ 'application_fee' => { order: 'asc' } }]
      when 'application_fee_desc'
        search_definition[:sort] = [{ 'application_fee' => { order: 'desc' } }]
      when 'tuition_fee_asc'
        search_definition[:sort] = [{ 'tuition_fee_international' => { order: 'asc' } }]
      when 'tuition_fee_desc'
        search_definition[:sort] = [{ 'tuition_fee_international' => { order: 'desc' } }]
      when 'course_duration_asc'
        search_definition[:sort] = [{ 'course_duration' => { order: 'asc' } }]
      when 'course_duration_desc'
        search_definition[:sort] = [{ 'course_duration' => { order: 'desc' } }]
    end

      __elasticsearch__.search(search_definition)
    end


  # Custom Search Method for Courses, Subjects, and Tests
  def self.search_courses_and_subjects(query, limit: 100, min_fee: nil, max_fee: nil)
    # First try exact match search for better performance
    exact_courses = Course.joins(:universities)
                         .where("courses.name ILIKE ? OR courses.title ILIKE ? OR universities.name ILIKE ?", 
                               query, query, query)
                         .limit(limit)
                         .includes(:universities)

    # If we don't have enough results, try fuzzy search
    if exact_courses.count < limit
      search_query = {
        query: {
          bool: {
            must: [
              {
                multi_match: {
                  query: query,
                  fields: %w[name course_code level_of_course delivery_method current_status module_subjects],
                  fuzziness: 'AUTO'
                }
              }
            ]
          }
        },
        size: limit - exact_courses.count
      }
    
      # Add tuition fee range filter if present
      if min_fee || max_fee
        min_fee ||= 0
        max_fee ||= Float::INFINITY
        search_query[:query][:bool][:filter] = {
          range: { tuition_fee_international: { gte: min_fee, lte: max_fee } }
        }
      end
    
      # Search in courses using Elasticsearch
      fuzzy_courses = __elasticsearch__.search(search_query).records.includes(:universities)
      
      # Combine exact and fuzzy results
      course_results = (exact_courses + fuzzy_courses).uniq
    else
      course_results = exact_courses
    end

    # Search in universities and get associated courses
    university_results = University.where("name ILIKE ?", "%#{query}%")
                                 .limit(10) # Limit university results
    university_courses = Course.joins(:universities)
                             .where(universities: { id: university_results.pluck(:id) })
                             .limit(limit) # Limit university courses
                             .includes(:universities)

    # Combine all results and limit to requested size
    all_courses = (course_results + university_courses).uniq.take(limit)
    
    # Group courses by university
    courses_by_university = all_courses.group_by { |course| course.universities.first }

    # Search subjects and tests with limits
    {
      courses_by_university: courses_by_university,
      subjects: Subject.search_subjects(query, limit: 10),
      tests: StandardizedTest.search_tests(query, limit: 10)
    }
  end
end