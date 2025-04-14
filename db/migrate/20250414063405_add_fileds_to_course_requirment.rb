class AddFiledsToCourseRequirment < ActiveRecord::Migration[7.1]
 def change
    add_column :course_requirements, :pte_reading, :string
    add_column :course_requirements, :toefl_overall, :string
    add_column :course_requirements, :pte_writing, :string
    add_column :course_requirements, :ielts_writing, :string
    add_column :course_requirements, :toefl_reading, :string
    add_column :course_requirements, :ielts_overall, :string
    add_column :course_requirements, :toefl_listening, :string
    add_column :course_requirements, :ielts_reading, :string
    add_column :course_requirements, :toefl_speaking, :string
    add_column :course_requirements, :ielts_listening, :string
    add_column :course_requirements, :toefl_writing, :string
    add_column :course_requirements, :pte_overall, :string
    add_column :course_requirements, :ielts_speaking, :string
    add_column :course_requirements, :pte_speaking, :string
    add_column :course_requirements, :pte_listening, :string

    add_column :course_requirements, :year_12_english_telangana_board, :string
    add_column :course_requirements, :year_12_english_gujarat_board, :string
    add_column :course_requirements, :year_12_english_karnataka_board, :string
    add_column :course_requirements, :year_12_english_tamil_nadu_board, :string
    add_column :course_requirements, :year_12_english_punjab_board, :string
    add_column :course_requirements, :year_12_english_cbse_isc, :string
    add_column :course_requirements, :year_12_english_haryana_board, :string
    add_column :course_requirements, :year_12_english_nios, :string
    add_column :course_requirements, :year_12_english_maharashtra_board, :string
    add_column :course_requirements, :year_12_english_andhra_pradesh_board, :string
    add_column :course_requirements, :year_12_english_west_bengal_board, :string
    add_column :course_requirements, :year_12_english_ib, :string
    add_column :course_requirements, :year_12_english_other_boards, :string

    add_column :course_requirements, :remarks_on_course_description, :string
    add_column :course_requirements, :class_12_cbse_isc_overall, :string
    add_column :course_requirements, :class_12_state_boards_overall, :string
    add_column :course_requirements, :class_12_nios_overall, :string
    add_column :course_requirements, :class_12_ib_overall, :string

    add_column :course_requirements, :class_12_indian_physics, :string
    add_column :course_requirements, :class_12_ib_chemistry, :string
    add_column :course_requirements, :class_12_gce_physics, :string
    add_column :course_requirements, :class_12_gce_math, :string
    add_column :course_requirements, :class_10_indian_board_overall, :string
    add_column :course_requirements, :class_12_ib_physics, :string
    add_column :course_requirements, :class_12_ib_math, :string
    add_column :course_requirements, :class_10_gcse_overall, :string
    add_column :course_requirements, :class_12_indian_chemistry, :string
    add_column :course_requirements, :class_10_indian_board_mathematics, :string
    add_column :course_requirements, :class_12_gce_chemistry, :string
    add_column :course_requirements, :class_12_indian_math, :string
    add_column :course_requirements, :class_12_gce_overall, :string
    add_column :course_requirements, :class_12_ib_biology, :string
    add_column :course_requirements, :class_12_gce_biology, :string
    add_column :course_requirements, :class_12_indian_biology, :string

    add_column :course_requirements, :grad_score_required_3_tier1, :string
    add_column :course_requirements, :grad_score_required_3_tier2, :string
    add_column :course_requirements, :grad_score_required_3_tier3, :string

    add_column :course_requirements, :current_status, :string
    add_column :course_requirements, :class_10_gcse_math, :string

    add_column :course_requirements, :year_12_english_chhattisgarh_board, :string
    add_column :course_requirements, :year_12_english_madhya_pradesh_board, :string
    add_column :course_requirements, :year_12_english_jk_board, :string
    add_column :course_requirements, :year_12_english_kerala_board, :string
    add_column :course_requirements, :year_12_english_rajasthan_board, :string

    add_column :course_requirements, :moi_state_exceptions, :string
    add_column :course_requirements, :entrance_exam_score, :string

    add_column :course_requirements, :grad_score_required_4plus_tier2, :string
    add_column :course_requirements, :grad_score_required_4plus_tier1, :string

    add_column :course_requirements, :currency_for_fee, :string
  end
end
