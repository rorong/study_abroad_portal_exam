class SearchesController < ApplicationController
#   skip_before_action :authenticate, only: [:index]
allow_unauthenticated_access only: %i[ index]

  def index
    @query = params[:query]
    @filters = build_filters
    
    @courses = if @query.present?
      Course.search(@query, 
        where: @filters,
        fields: [
          # Core course information - higher boost for primary fields
          'name^4',                    # Course name gets highest boost
          'title^3',                   # Course title gets high boost
          'course_code^2',             # Course code gets medium boost
          'module_subjects^2',         # Module subjects get medium boost
          
          # Related model names
          'institution_name^2',        # Institution name gets medium boost
          'department_name^2',         # Department name gets medium boost
          'tag_name',                  # Tags
          
          # Course details
          'level_of_course',
          'delivery_method',
          'intake',
          'department',
          'record_status',
          
          # URLs and external links
          'course_weblink',
          'course_image'
        ],
        match: :word_start,
        misspellings: { below: 5 },
        includes: [:institution, :department, :course_requirement, :tags, :remarks] # Include all related models
      )
    else
      Course.none
    end
  end

  private

  def build_filters
    filters = { delete_record: false }
    
    # Basic filters
    filters[:institution_id] = params[:institution_id] if params[:institution_id].present?
    filters[:department_id] = params[:department_id] if params[:department_id].present?
    filters[:level_of_course] = params[:level] if params[:level].present?
    
    # Course status filters
    filters[:record_status] = params[:status] if params[:status].present?
    filters[:locked] = params[:locked] if params[:locked].present?
    filters[:is_record_duplicate] = false # Always filter out duplicates
    
    # International student filters
    if params[:international].present?
      filters[:international_students_allowed] = true
    end

    # Fee filters
    if params[:min_fee].present? || params[:max_fee].present?
      filters[:tuition_fee_international] = {
        gte: params[:min_fee].presence || 0,
        lte: params[:max_fee].presence || Float::INFINITY
      }
    end

    # Duration and intake filters
    filters[:course_duration] = params[:duration] if params[:duration].present?
    filters[:intake] = params[:intake] if params[:intake].present?
    
    # Requirement filters
    if params[:requirements].present?
      filters[:course_requirement] = {
        cv_mandatory: params[:cv_required],
        lor_mandatory: params[:lor_required],
        sop_mandatory: params[:sop_required],
        interview_mandatory: params[:interview_required],
        sealed_transcript_mandatory: params[:transcript_required],
        attested_docs_mandatory: params[:attested_docs_required],
        color_scan_mandatory: params[:color_scan_required]
      }.compact
    end

    # Academic filters
    if params[:min_work_exp].present?
      filters[:min_work_experience_years] = { gte: params[:min_work_exp] }
    end

    if params[:gap_year].present?
      filters[:gap_after_degree] = { lte: params[:gap_year] }
    end

    # Test score filters
    if params[:gmat].present?
      filters[:gmat_score] = { gte: params[:gmat] }
    end

    if params[:gre].present?
      filters[:gre_score] = { gte: params[:gre] }
    end

    if params[:sat].present?
      filters[:sat_score] = { gte: params[:sat] }
    end

    filters
  end
end 