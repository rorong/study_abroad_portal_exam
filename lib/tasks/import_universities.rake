require 'csv'

namespace :import do
  desc "Import university data from a CSV file"
  task universities: :environment do
    file_path = "University_001.csv"

    CSV.foreach(file_path, headers: true, liberal_parsing: true).each_with_index do |row, index|
      puts ">>>>>>>> Importing University #{index + 1} <<<<<<<<<<<"

      begin
        ActiveRecord::Base.transaction do
          # Handle Created By user
          created_by_user = User.find_or_create_by(record_id: row["Created By.id"]) do |user|
            user.email = "user_#{row["Created By.id"]}@example.com"
            user.password = SecureRandom.hex(8)
            user.role = "student"
          end

          # Handle Modified By user
          modified_by_user = User.find_or_create_by(record_id: row["Modified By.id"]) do |user|
            user.email = "user_#{row["Modified By.id"]}@example.com"
            user.password = SecureRandom.hex(8)
            user.role = "student"
          end

          university = University.find_or_initialize_by(record_id: row["Record Id"])
          university.assign_attributes(
            university_owner_id: row["Universities Owner.id"],
            name: row["Universities Name"],
            code: row["Universities Code"],
            vendor_id: row["Vendor Name.id"],
            active: row["Universities Active"] == "true",
            manufacturer: row["Manufacturer"],
            category: row["Universities Category"],
            sales_start_date: row["Sales Start Date"],
            sales_end_date: row["Sales End Date"],
            support_start_date: row["Support Start Date"],
            support_end_date: row["Support End Date"],
            created_by_id: created_by_user.record_id,
            modified_by_id: modified_by_user.record_id,
            unit_price: row["Unit Price"],
            commission_rate: row["Commission Rate"],
            tax: row["Tax"],
            usage_unit: row["Usage Unit"],
            qty_ordered: row["Qty Ordered"],
            quantity_in_stock: row["Quantity in Stock"],
            reorder_level: row["Reorder Level"],
            handler_id: row["Handler.id"],
            quantity_in_demand: row["Quantity in Demand"],
            description: row["Description"],
            taxable: row["Taxable"] == "true",
            currency: row["Currency"],
            exchange_rate: row["Exchange Rate"],
            layout_id: row["Layout.id"],
            tag: row["Tag"],
            image: row["Universities Image"],
            see_financial_docs_before_visa: row["Do they see financial docs before visa letter"] == "true",
            see_financial_docs_before_offer: row["Do they wish to see financial docs before offer"] == "true",
            ask_deposit_before_visa: row["Do they ask for deposit before visa letter"] == "true",
            ask_deposit_conditional_offer: row["Do they ask for deposit of conditional offer"] == "true",
            city: row["City"],
            address: row["Address"],
            country: row["Country"],
            state: row["State"],
            switchboard_no: row["Switchboard No"],
            post_code: row["Post Code"],
            aec_account_manager: row["AEC's Account Manager"],
            application_process_type: row["Application Process Type"],
            aec_account_manager_mobile: row["AEC's Account Manager Mobile"],
            aec_account_manager_email: row["AEC's Account Manager Email"],
            international_manager_phone: row["International Manager Phone"],
            contract_valid_till: row["Contract valid till"],
            international_manager_name: row["International Manager Name"],
            accounts_executive_name: row["Accounts Executive Name (to claim commission)"],
            international_manager_email: row["International Manager Email"],
            need_sop: row["Do they need SOP for applications"] == "true",
            accounts_executive_phone: row["Accounts Executive Phone"],
            accounts_executive_email: row["Accounts Executive Email"],
            interview_before_offer: row["Do they take an interview before releasing offer"] == "true",
            need_lor: row["Do they need LOR for every application"] == "true",
            other_useful_contact: row["Any other useful contact"],
            website: row["University Website"],
            turnaround_time_days: row["University Turnaround Time for decisions (in days)"]&.to_i,
            interview_before_visa: row["Do they take an interview before visa letter"] == "true",
            accept_agent_appointment: row["Do they accept appointment of agent"] == "true",
            accept_agent_change: row["Do they accept Change of Agent"] == "true",
            processed_through: row["Processed Through"],
            user_modified_time: row["User Modified Time"],
            system_activity_time: row["System Related Activity Time"],
            user_activity_time: row["User Related Activity Time"],
            system_modified_time: row["System Modified Time"],
            the_world_ranking: row["THE World Ranking (Latest)"],
            qs_world_ranking_latest: row["QS World Ranking (Latest)"],
            national_ranking: row["National Ranking"],
            established_in: row["Established In"],
            total_international_students: row["Total International Students"],
            total_students: row["Total number of students"],
            type_of_university: row["Type of University"],
            application_fee: row["Application Fee"],
            conditional_offers: row["Do they issue Conditional Offers"] == "true",
            lateral_entry_allowed: row["Is Lateral Entry Allowed"] == "true",
            total_staff: row["Total Staff"],
            address_2: row["Address 2"],
            scholarship_details: row["Please enter the details of scholarships available"],
            notable_alumni: row["Notable Alumni (just names and designation / role)"],
            affiliations: row["Affiliations"],
            misc_rankings: row["Rankings - Miscellaneous"],
            number_of_campuses: row["Number of Campus"],
            campus_size_acres: row["Campus Size (in Acres)"],
            campus_location: row["Location of Campus"],
            tier: row["Which Tier"],
            record_status: row["Record Status"],
            locked: row["Locked"] == "true"
          )

          if row["Latitude Longitude"].present?
            lat_long = row["Latitude Longitude"].split(/[\,\s]+/)
            if lat_long.length >= 2
              university.latitude = lat_long[0].strip
              university.longitude = lat_long[1].strip
            end
          end

          university.save!(validate: false)

          if university.university_owner_id.blank?
            puts "⚠️ Warning: University #{university.name} does not have an owner ID!"
          end

          # if university.university_owner_id.present?
          #   courses = Course.where(institution_id: university.university_owner_id)
          #   courses.each do |course|
          #     CourseUniversity.find_or_create_by(course: course, university: university)
          #   end
          # end

          puts "✅ Successfully imported university: #{university.name} (Owner ID: #{university.university_owner_id})"
        end

      rescue StandardError => e
        puts "❌ Error importing row #{index + 1}: #{e.message}"
        next
      end
    end
  end
end
