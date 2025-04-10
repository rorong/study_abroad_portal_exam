require 'csv'

namespace :import do
  desc "Import university data from a CSV file"
  task universities: :environment do
    file_path = "University_001.csv"

    CSV.foreach(file_path, headers: true, liberal_parsing: true).each_with_index do |row, index|
      puts ">>>>>>>> Importing University #{index + 1} <<<<<<<<<<<"

      begin
        ActiveRecord::Base.transaction do
          university = University.find_or_initialize_by(record_id: row["Record Id"]) do |uni|
            uni.university_owner_id = row["Universities Owner.id"] # Ensure this is correctly assigned
            uni.name = row["Universities Name"]
            uni.code = row["Universities Code"]
            uni.active = row["Universities Active"] == "true"
            uni.category = row["Universities Category"]
            uni.city = row["City"]
            uni.address = row["Address"]
            uni.country = row["Country"]
            uni.state = row["State"]
            uni.switchboard_no = row["Switchboard No"]
            uni.post_code = row["Post Code"]
            uni.website = row["University Website"]
            uni.world_ranking = row["THE World Ranking (Latest)"]&.to_i
            uni.qs_ranking = row["QS World Ranking (Latest)"]&.to_i
            uni.national_ranking = row["National Ranking"]&.to_i
            uni.established_in = row["Established In"]&.to_i
            uni.total_students = row["Total number of students"]&.to_i
            uni.total_international_students = row["Total International Students"]&.to_i
            uni.type_of_university = row["Type of University"]
            uni.application_fee = row["Application Fee"]&.to_f
            uni.conditional_offers = row["Do they issue Conditional Offers"] == "true"
            uni.lateral_entry_allowed = row["Is Lateral Entry Allowed"] == "true"
            uni.on_campus_accommodation = row["On Campus Accommodation available"] == "true"
            if row["Latitude Longitude"].present?
              lat_long = row["Latitude Longitude"].split(/[,\s]+/)
              if lat_long.length >= 2
                uni.latitude = lat_long[0].strip
                uni.longitude = lat_long[1].strip
              end
            end
          end
          university.save!(validate: false)

          # courses = Course.where(institution_id: university.university_owner_id)
          # courses.each do |course|
          #   CourseUniversity.find_or_create_by(course: course, university: university)
          # end
          if university.university_owner_id.blank?
            puts "⚠️ Warning: University #{university.name} does not have an owner ID!"
          end

          # **🔹 Assign Courses to University using university_owner_id**
          if university.university_owner_id.present?
            courses = Course.where(institution_id: university.university_owner_id)
            courses.each do |course|
              CourseUniversity.find_or_create_by(course: course, university: university)
            end
          end

          puts "✅ Successfully imported university: #{university.name} (Owner ID: #{university.university_owner_id})"
        end

      rescue StandardError => e
        puts "❌ Error importing row #{index + 1}: #{e.message}"
        next
      end
    end
  end
end
