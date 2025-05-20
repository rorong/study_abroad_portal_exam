require 'csv'
require 'bcrypt'

namespace :import do
  desc "Import data from a CSV file"
  task courses: :environment do
    file_path = "latest_data/Courses_C_001.csv"

    CSV.foreach(file_path, headers: true, liberal_parsing: true).each_with_index do |row, index|
      begin
        ActiveRecord::Base.transaction do
          # Find or create owner user
          # OWNER
          agency = Agency.find_or_create_by(name: 'ongraph') do |a|
            a.subdomain = 'ongraph'
          end
          owner_email = row['Email'] || row['Secondary Email'] || "user_#{row['Course Owner.id']}@example.com"
          owner = User.find_by(email: owner_email) || User.find_or_initialize_by(record_id: row["Record Id"])
          if owner.new_record?
            owner.email = owner_email
            owner.email_opt_out = row['Email Opt Out'] == 'true'
            owner.password = 'password123'
            owner.agency_id = agency.id
            owner.save! # use bang to raise on validation errors
          end

          # CREATOR
          creator_email = "user_#{row['Created By.id']}@example.com"
          creator = User.find_by(email: creator_email) || User.find_by(record_id: row["Created By.id"]) || User.new
          if creator.new_record?
            creator.assign_attributes(
              record_id: row["Created By.id"],
              email: creator_email,
              password: 'password123',
              agency_id: agency.id
            )
            creator.save! if creator.valid?
          end

          # MODIFIER
          modifier_email = "user_#{row['Modified By.id']}@example.com"
          modifier = User.find_by(email: modifier_email) || User.find_by(record_id: row["Modified By.id"]) || User.new
          if modifier.new_record?
            modifier.assign_attributes(
              record_id: row["Modified By.id"],
              email: modifier_email,
              password: 'password123',
              agency_id: agency.id
            )
            modifier.save! if modifier.valid?
          end


          department = Department.find_or_create_by(name: row['Department'])
          tag = Tag.find_or_create_by(tag_name: row['Tag'])
          currency = Currency.find_or_create_by(currency_code: row['Currency'], exchange_rate: row['Exchange Rate'])

          # Create Course record
          course = Course.new(
            record_id: row['Record Id'],
            name: row['Course Name'],
            owner_id: owner.id,
            creator_id: creator.id,
            modifier_id: modifier.id,
            created_at: row['Created Time'],
            updated_at: row['Modified Time'],
            last_activity_time: row['Last Activity Time'],
            layout_id: row['Layout.id'],
            user_modified_time: row['User Modified Time'],
            system_modified_time: row['System Modified Time'],
            user_related_activity_time: row['User Related Activity Time'],
            system_related_activity_time: row['System Related Activity Time'],
            record_approval_status: row['Record Approval Status'],
            is_record_duplicate: row['Is Record Duplicate'] == 'true',
            course_image: row['Course Image'],
            course_weblink: row['Course Weblink'],
            level_of_course: row['Level of Course'],
            course_code: row['Course Code'],
            course_duration: row['Course Duration (in months)'],
            university_id: row['Institute Name.id'],
            department_id: department.id,
            title: row['Course Title'],
            tuition_fee_international: row['Tuition Fee (International - Per Annum)'],
            application_fee: row['Application Fee'],
            tuition_fee_local: row['Tuition Fee (Local - Per Annum)'],
            intake: row['Intake'],
            delivery_method: row['Delivery Method'],
            internship_period: row['Internship Period (in weeks)'],
            delete_record: row['Should we delete this record'] == 'true',
            locked: row['Locked'] == 'true',
            record_status: row['Record Status'],
            allow_backlogs: row['Number of Backlogs accepted'],
            module_subjects: row["Modules / Subjects Taught"]&.gsub("\n", " ")
          )
          course.save(validate: false)

          CourseTag.create(course: course, tag: tag)

          # Create CourseRequirement record
          CourseRequirement.create(
            course: course,
            selt_waived_off: row['Can SELT be waived off'] == 'true',
            type_of_ielts_required: row['Type of IELTS required'],
            previous_degree_subject: row['Previous degree or diploma in which subject'],
            similar_subjects_tags: row['Similar Subjects (Tags)'],
            unsubscribed_mode: row['Unsubscribed Mode'],
            unsubscribed_time: row['Unsubscribed Time'],
            cv_mandatory: row['Is CV Mandatory'] == 'true',
            lor_mandatory: row['Is LOR Mandatory'] == 'true',
            sop_mandatory: row['Is SOP Mandatory'] == 'true',
            color_scan_mandatory: row['Is Colour Scan Copy of Documents Mandatory'] == 'true',
            international_students_allowed: row['Availability for International Students'],
            interview_mandatory: row['Is Interview Mandatory'] == 'true',
            sealed_transcript_mandatory: row['Is Sealed Transcript Mandatory'] == 'true',
            attested_docs_mandatory: row['Are Attested Documents Mandatory'] == 'true',
            change_of_agent_allowed: row['Is Change of Agent Allowed'] == 'true',
            agent_appointment_allowed: row['Is Appointment of Agent Allowed'] == 'true',
            lateral_entry_possible: row['Possibility of Lateral Entry'] == 'true',
            initial_fee_visa_letter: row['Initial Fee Required for visa letter'],
            min_work_experience_years: row['Minimum Work Experience Required (in years)'],
            gap_after_degree: row['Gap Acceptable after degree (no of yrs)'],
            gap_after_class_12_years: row['Gap Acceptable after Class 12 (no of years)'],
            doubts_or_observations: row['Please mention your doubts or observations here'],
            grad_validity_moi_months: row['Validity of Graduation No of Months for MOI'],
            moi_tier1_accepted: row['Tier 1 University degree is accepted for MOI'] == 'true',
            moi_tier2_accepted: row['Tier 2 University degree is accepted for MOI'] == 'true',
            moi_tier3_accepted: row['Tier 3 University degree is accepted for MOI'] == 'true',
            moi_any_university_accepted: row['Any University degree is accepted for MOI'] == 'true',
            work_experience_factor: row['Work Experience Factor'],
            previous_academic_grades: row['Previous Academic Grades'],
            all_rounder_capabilities: row['All Rounder Capabilities'],
            admission_process_notes: row['Any other information related to admission process'],
            weightage_class_10: row['Weightage for Class 10'],
            weightage_class_12: row['Weightage for Class 12 Grades'],
            weightage_grad_score: row['Weightage for Grad Score'],
            gmat_score: row['GMAT Score'],
            gre_score: row['GRE Score'],
            sat_score: row['SAT Score'],
            pte_reading: row['PTE Reading'],
            toefl_overall: row['TOEFL Overall'],
            pte_writing: row['PTE Writing'],
            ielts_writing: row['IELTS Writing'],
            toefl_reading: row['TOEFL Reading'],
            ielts_overall: row['IELTS Overall'],
            toefl_listening: row['TOEFL Listening'],
            ielts_reading: row['IELTS Reading'],
            toefl_speaking: row['TOEFL Speaking'],
            ielts_listening: row['IELTS Listening'],
            toefl_writing: row['TOEFL Writing'],
            pte_overall: row['PTE Overall'],
            ielts_speaking: row['IELTS Speaking'],
            pte_speaking: row['PTE Speaking'],
            pte_listening: row['PTE Listening'],
            year_12_english_telangana_board: row['Year 12 English (Telangana Board)'],
            year_12_english_gujarat_board: row['Year 12 English (Gujarat Board)'],
            year_12_english_karnataka_board: row['Year 12 English (Karnataka Board)'],
            year_12_english_tamil_nadu_board: row['Year 12 English (Tamil Nadu Board)'],
            year_12_english_punjab_board: row['Year 12 English (Punjab State Board)'],
            year_12_english_cbse_isc: row['Year 12 English (CBSE / ISC)'],
            year_12_english_haryana_board: row['Year 12 English (Haryana Board)'],
            year_12_english_nios: row['Year 12 English (NIOS)'],
            year_12_english_maharashtra_board: row['Year 12 English (Maharashtra Board)'],
            year_12_english_andhra_pradesh_board: row['Year 12 English (Andhra Pradesh Board)'],
            year_12_english_west_bengal_board: row['Year 12 English (West Bengal Board)'],
            year_12_english_ib: row['Year 12 English (IB)'],
            year_12_english_other_boards: row['Year 12 English (other State Boards)'],
            remarks_on_course_description: row['Remarks (related to Course Description)'],
            class_12_cbse_isc_overall: row['Class 12 CBSE/ISC Board Overall'],
            class_12_state_boards_overall: row['Class 12 Indian State Boards Overall'],
            class_12_nios_overall: row['Class 12 NIOS Board Overall'],
            class_12_ib_overall: row['Class 12 IB Board Overall'],
            class_12_indian_physics: row['Class 12 Indian Board Physics Requirement'],
            class_12_ib_chemistry: row['Class 12 IB Board Chemistry Requirement'],
            class_12_gce_physics: row['Class 12 GCE Board Physics Requirement'],
            class_12_gce_math: row['Class 12 GCE Board Mathematics Requirement'],
            class_10_indian_board_overall: row['Class 10 Indian Board Overall'],
            class_12_ib_physics: row['Class 12 IB Board Physics Requirement'],
            class_12_ib_math: row['Class 12 IB Board Mathematics Requirement'],
            class_10_gcse_overall: row['Class 10 GCSE Overall'],
            class_12_indian_chemistry: row['Class 12 Indian Board Chemistry Requirement'],
            class_10_indian_board_mathematics: row['Class 10 Indian Board Mathematics Requirement'],
            class_12_gce_chemistry: row['Class 12 GCE Board Chemistry Requirement'],
            class_12_indian_math: row['Class 12 Indian Board Mathematics Requirement'],
            class_12_gce_overall: row['Class 12 GCE Overall'],
            class_12_ib_biology: row['Class 12 IB Board Biology Requirement'],
            class_12_gce_biology: row['Class 12 GCE Board Biology Requirement'],
            class_12_indian_biology: row['Class 12 Indian Board Biology Requirement'],
            grad_score_required_3_tier1: row['Grad Score Required 3 Yrs Indian Tier 1 University'],
            grad_score_required_3_tier2: row['Grad Score Required 3 Yrs Indian Tier 2 University'],
            grad_score_required_3_tier3: row['Grad Score Required 3 Yrs Indian Tier 3 University'],
            current_status: row['Current Status'],
            class_10_gcse_math: row['Class 10 GCSE Board Mathematics Requirement'],
            year_12_english_chhattisgarh_board: row['Year 12 English (Chhattisgarh Board)'],
            year_12_english_madhya_pradesh_board: row['Year 12 English (Madhya Pradesh Board)'],
            year_12_english_jk_board: row['Year 12 (Jammu and Kashmir Board)'],
            year_12_english_kerala_board: row['Year 12 English (Kerala Board)'],
            year_12_english_rajasthan_board: row['Year 12 English (Rajasthan Board)'],
            moi_state_exceptions: row['Which states are not accepted for MOI'],
            entrance_exam_score: row['Entrance Exam Score'],
            grad_score_required_4plus_tier2: row['Grad Score Reqd 4+ Yrs Indian Tier 2 University'],
            grad_score_required_4plus_tier1: row['Grad Score Reqd 4+ Yrs Indian Tier 1 University'],
            currency_for_fee: row['Currency for fee']
          )

          Remark.create(
            course: course,
            user_id: owner.id,
            remarks_course_desc: row['Remarks (related to Course Description)'],
            remarks_selt: row['Remarks (related to SELT)'],
            remarks_entry_req: row['Remarks Related to Entry Requirements (if any)']
          )

          puts "Successfully imported course: #{course.name}"
        end

      rescue StandardError => e
        puts "Error importing row #{index}: #{e.message}"
        next
      end
    end


    #university data
    file_path_uni = "latest_data/University_001.csv"

    CSV.foreach(file_path_uni, headers: true, liberal_parsing: true).each_with_index do |row, index|
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

    #courses_universities data
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