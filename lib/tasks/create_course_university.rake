# namespace :import do
#     desc "Create Course University "
#     task course_universities: :environment do
#         Institution.all.each do |institution|
#             courses = institution.courses
#             universities = institution.universities
            
#             courses.each do |course|
#                 universities.each do |university|
#                     CourseUniversity.find_or_create_by!(
#                         course_id: course.id,
#                         university_id: university.id
#                     )
#                 end
#             end
#         end
#         puts "Course Universities created successfully!"
#     end
# end

# namespace :import do
#   desc "Create CourseUniversity records for all courses and universities under each institution"
#   task course_universities: :environment do
#     ActiveRecord::Base.logger.silence do
#       institutions = Institution.includes(:courses, :universities)

#       institutions.find_each do |institution|
#         courses = institution.courses
#         universities = institution.universities

#         next if courses.empty? || universities.empty?

#         # Get all existing CourseUniversity records for the current institution
#         existing_records = CourseUniversity.where(
#           course_id: courses.pluck(:id),
#           university_id: universities.pluck(:id)
#         ).pluck(:course_id, :university_id).to_set

#         new_records = []

#         courses.each do |course|
#           universities.each do |university|
#             # Skip if CourseUniversity already exists
#             unless existing_records.include?([course.id, university.id])
#               new_records << {
#                 course_id: course.id,
#                 university_id: university.id,
#                 created_at: Time.current,
#                 updated_at: Time.current
#               }
#             end
#           end
#         end

#         # Bulk insert only if there are new records
#         if new_records.any?
#           CourseUniversity.insert_all(new_records)
#           puts "✅ Created #{new_records.size} CourseUniversity records for Institution #{institution.id}"
#         else
#           puts "⚡️ No new CourseUniversity records needed for Institution #{institution.id}"
#         end
#       end
#     end

#     puts "🎉 CourseUniversity records have been created successfully!"
#   end
# end
# lib/tasks/import_course_universities.rake
namespace :import do
  desc "Create CourseUniversity records where university_owner_id matches institution record_id"
  task course_universities: :environment do
    created_count = 0
    Course.find_each do |course|
      institution_record_id = course.institution&.record_id
      next unless institution_record_id.present?

      universities = University.where(record_id: institution_record_id)
      universities.each do |university|
        unless CourseUniversity.exists?(course_id: course.id, university_id: university.id)
          CourseUniversity.create!(course_id: course.id, university_id: university.id)
          created_count += 1
          puts "✅ Successfully created #{created_count} CourseUniversity records!"
        end
      end
    end

    puts "✅ Successfully created #{created_count} CourseUniversity records!"
  end
end
