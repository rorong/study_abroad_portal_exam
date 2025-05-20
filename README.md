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
CHECK VERIFY MAPPINGS FOR EACH MODEL

curl -X GET "http://elastic:12345678@localhost:9200/courses/_mapping?pretty"

 curl -X GET "http://elastic:12345678@localhost:9200/courses/_search?pretty" -H 'Content-Type: application/json' -d '


curl -X GET "http://elastic:12345678@localhost:9200/courses/_search?pretty" -H 'Content-Type: application/json' -d '
{
  "query": {
    "nested": {
      "path": "universities",
      "query": {
        "exists": { "field": "universities.location" }
      }
    }
  },
  "_source": ["universities.name", "universities.location"],
  "size": 5
}'



courses = Course.advanced_search('', {"lateral_entry_possible": false}, "application_fee_asc").records.count


-----
To reindex
run common method for each after any changes

Course.reindex_all
CourseRequirement.reindex_all
University.reindex_all
Tag.reindex_all
Department.reindex_all




-----
Elastic 
URL:
https://my-deployment-6ed54b.es.asia-south1.gcp.elastic-cloud.com


password
RWP86UZLe9UhqQigdZjUODb9


---
1. create new db with 1lakh records
2. clean data to save in new column

Course.find_each do |course|
  puts "course id======= #{course.id}"
  clean_text = course.module_subjects.to_s.gsub(/[^a-zA-Z0-9\s]/, '').squish
  course.update_column(:course_module, clean_text)
end

3.
DELETE EXISTING INDEXES

TO DELETE:
Course.__elasticsearch__.client.indices.delete(index: 'courses') rescue nil


4.
REINDEX---

Create index as we deleted above:
Course.__elasticsearch__.create_index!(index: 'courses', force: true)


5. Index/Import data in batch 

client = Course.__elasticsearch__.client

Course.find_in_batches(batch_size: 1000) do |batch|
  body = batch.flat_map do |course|
    [
      { index: { _index: 'courses', pipeline: 'elser-ingest-pipeline', _id: course.id } },
      course.as_indexed_json
    ]
  end

  client.bulk(body: body)
end





TO CHECK INDEX/IMPORT DATA
curl -u "elastic:RWP86UZLe9UhqQigdZjUODb9" \
  https://my-deployment-6ed54b.es.asia-south1.gcp.elastic-cloud.com/_cat/indices?v
