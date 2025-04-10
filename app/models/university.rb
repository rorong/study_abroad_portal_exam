class University < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    has_many :course_universities, dependent: :destroy
    has_many :courses, through: :course_universities
    belongs_to :institution, 
    foreign_key: 'university_owner_id', 
    primary_key: 'id', 
    optional: true
    has_many :university_contacts, dependent: :destroy
    has_many :university_rankings, dependent: :destroy
    has_many :university_application_processes, dependent: :destroy
    has_many :institutions, foreign_key: 'record_id', primary_key: 'record_id'

    # Associations with User (for created_by, modified_by, etc.)
    belongs_to :owner, class_name: 'User', optional: true
    belongs_to :creator, class_name: 'User', optional: true
    belongs_to :modifier, class_name: 'User', optional: true
    belongs_to :institution, foreign_key: 'university_owner_id', primary_key: 'record_id', optional: true
    validates :record_id, :name, presence: true
  end
  