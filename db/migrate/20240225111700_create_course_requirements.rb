class CreateCourseRequirements < ActiveRecord::Migration[7.0]
  def change
    create_table :course_requirements do |t|
      t.references :course, foreign_key: true
      t.boolean :selt_waived_off
      t.string :type_of_ielts_required
      t.float :weightage_class_10
      t.float :weightage_class_12
      
      # Academic requirements
      t.float :grad_score_required_3yrs_tier1
      t.float :grad_score_required_3yrs_tier2
      t.float :grad_score_required_3yrs_tier3
      t.float :grad_score_required_4yrs_tier1
      t.float :grad_score_required_4yrs_tier2
      t.float :grad_score_required_4yrs_tier3
      t.float :weightage_grad_score
      
      # Additional requirements
      t.integer :num_backlogs_accepted
      t.float :min_work_experience_years
      t.float :initial_fee_visa_letter
      t.boolean :lateral_entry_possible
      t.boolean :agent_appointment_allowed
      t.boolean :cv_mandatory
      t.boolean :lor_mandatory
      t.boolean :sop_mandatory
      t.boolean :interview_mandatory
      t.boolean :sealed_transcript_mandatory
      t.boolean :attested_docs_mandatory
      t.boolean :change_of_agent_allowed
      t.boolean :color_scan_mandatory
      t.boolean :international_students_allowed
      
      # Other fields
      t.string :previous_degree_subject
      t.string :similar_subjects_tags
      t.boolean :unsubscribed_mode
      t.datetime :unsubscribed_time
      t.float :gap_after_class_12_years
      t.text :doubts_or_observations
      t.integer :grad_validity_moi_months
      t.string :moi_restricted_states
      t.boolean :moi_tier1_accepted
      t.boolean :moi_tier2_accepted
      t.boolean :moi_tier3_accepted
      t.boolean :moi_any_university_accepted
      t.float :work_experience_factor
      t.string :fee_currency
      t.text :admission_process_notes    
      t.integer :gap_after_degree
      t.integer :previous_academic_grades
      t.integer :all_rounder_capabilities
      t.string :gmat_score
      t.string :gre_score
      t.string :sat_score

      t.timestamps
    end
  end
end 