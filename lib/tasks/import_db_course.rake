require 'csv'
require 'bcrypt'

namespace :import do
  desc "Import data from a CSV file"
  task db_courses: :environment do
    file_path = "Courses_C_001.csv"

    CSV.foreach(file_path, headers: true, liberal_parsing: true).each_with_index do |row, index|
      begin
        ActiveRecord::Base.transaction do
          # Find or create owner user
          owner = User.find_or_initialize_by(record_id: row["Record Id"]) do |user|
            user.email = (row['Email'] || row['Secondary Email'] || "user_#{row['Course Owner.id']}@example.com")
            user.email_opt_out = row['Email Opt Out'] == 'true'
            user.password = 'password123' # Devise will handle password encryption
          end
          owner.save(validate: false) if owner.new_record?

          # Find or create creator and modifier users
          creator = User.find_or_initialize_by(record_id: row["Created By.id"]) do |user|
            user.email = "user_#{row['Created By.id']}@example.com"
            user.password = 'password123' # Devise will handle password encryption
          end
          creator.save(validate: false) if creator.new_record?
          
          modifier = User.find_or_initialize_by(record_id: row["Modified By.id"]) do |user|
            user.email = "user_#{row['Modified By.id']}@example.com"
            user.password = 'password123' # Devise will handle password encryption
          end
          modifier.save(validate: false) if modifier.new_record?


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
  end
end