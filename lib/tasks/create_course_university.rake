namespace :import do
  desc "Link Courses and Universities through CourseUniversity based on CSV-based IDs"
  task link_course_universities: :environment do
    created_count = 0

    Course.find_each do |course|
      next unless course.university_id.present?

      # Match university where university.record_id == course.university_id
      matched_universities = University.where(record_id: course.university_id)

      matched_universities.each do |university|
        unless CourseUniversity.exists?(course_id: course.id, university_id: university.id)
          CourseUniversity.create!(course_id: course.id, university_id: university.id)
          created_count += 1
          puts "✅ Linked Course[#{course.id}] to University[#{university.id}]"
        end
      end
    end

    puts "🎉 Finished linking courses and universities. Total created: #{created_count}"
  end
end
