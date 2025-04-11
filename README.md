# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# study_abroad_portal_exam


#  Elasticsearch commands
Course.__elasticsearch__.create_index! force: true
Course.import

puts Elasticsearch::Model.client.count(index: 'courses')['count']



University.__elasticsearch__.create_index! force: true
University.import
puts Elasticsearch::Model.client.count(index: 'universities')['count']



Tag.__elasticsearch__.create_index! force: true
Tag.import
puts Elasticsearch::Model.client.count(index: 'tags')['count']


Department.__elasticsearch__.create_index! force: true
Department.import
puts Elasticsearch::Model.client.count(index: 'departments')['count']


CourseRequirement.__elasticsearch__.create_index! force: true
CourseRequirement.import

-------
curl -X GET "http://elastic:12345678@localhost:9200/courses/_mapping?pretty"

courses = Course.advanced_search('', {"lateral_entry_possible": false}, "application_fee_asc").records.count