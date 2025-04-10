class Course < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  
  has_many :course_universities, dependent: :destroy
  has_many :universities, through: :course_universities
  # Relationships
  belongs_to :owner, class_name: 'User'
  belongs_to :creator, class_name: 'User'
  belongs_to :modifier, class_name: 'User'
  belongs_to :institution
  belongs_to :department
  belongs_to :education_board, optional: true
  has_one :course_requirement, dependent: :destroy
  has_many :course_test_requirements, dependent: :destroy
  has_many :standardized_tests, through: :course_test_requirements
  has_many :course_subject_requirements, dependent: :destroy
  has_many :subjects, through: :course_subject_requirements
  has_many :remarks, dependent: :destroy
  has_many :course_tags, dependent: :destroy
  has_many :tags, through: :course_tags

  # Validations
  validates :name, :title, :course_code, :institution_id, :code, presence: true
  validates :code, uniqueness: true
  validates :duration_months, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :tuition_fee_international, :tuition_fee_local, :application_fee,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(should_delete: false) }
  scope :available_for_international, -> { where(international_students_eligible: true) }
  scope :unlocked, -> { where(locked: false) }

  # Elasticsearch Configuration
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :name, type: 'text'
      indexes :course_code, type: 'keyword'
      indexes :institution_id, type: 'keyword'
      indexes :department_id, type: 'integer'
      indexes :level_of_course, type: 'text'
      indexes :delivery_method, type: 'text'
      indexes :current_status, type: 'text'
      indexes :module_subjects, type: 'text'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
    end
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
