class CoursesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:search_page] 
  def search_page
    # This is the new landing page with just the search bar
  end

  def index
    return redirect_to root_url if params[:query].blank?
    # create filter hash and pass in below function
     # {"lateral_entry_possible": false}
     # {"min_tuition_fee": "10", "max_tuition_fee": "10"}

    #Pass sort filters hash according to params
    # Course.advanced_search(params[:query], {"lateral_entry_possible": false}, "application_fee_asc")
    filter = params.permit(
      :query,
      :distance, :latitude, :longitude,
      :intake, :level_of_course, :delivery_method, :current_status,
      :min_tuition_fee, :max_tuition_fee,
      :min_duration, :max_duration,
      :min_application_fee, :max_application_fee,
      :min_internship, :max_internship,
      :allow_backlogs,
      :lateral_entry_possible,
      :department_id,
      :type_of_university,
      :university_id, :university_country, :university_address,
      :min_world_ranking, :max_world_ranking,
      :min_qs_ranking, :max_qs_ranking,
      :min_national_ranking, :max_national_ranking,
      :tag_id
    ).to_h

    tag_ids = Array(params[:tag_id])
    filter[:tag_id] = tag_ids  if tag_ids.present?

    # Extract sort parameter
    sort = params[:sort]

    # Extract query parameter
    query = params[:query]

    # Get per_page parameter from request or use default
    per_page = params[:per_page].to_i
    per_page = 15 unless [5, 10, 15, 25, 50, 100].include?(per_page)

    # Ensure page is an integer >= 1
    page = params[:page].to_i
    page = 1 if page < 1
    
    # Run Elasticsearch advanced search
    search_result = Course.advanced_search(query, filter, sort, page, per_page)
    # Get total hit count from Elasticsearch
    total_count = search_result.response['hits']['total']['value'].to_i
    
    # Convert Elasticsearch hits to ActiveRecord models
    @search_courses = search_result.records
    # @similar_courses = Course.advanced_search(query, filter, sort, page, 200).records.order("RANDOM()")
    # # Paginate manually since we're using array-like records from ES
    # @courses = Kaminari.paginate_array(search_result.records.to_a, total_count: total_count)
    #                .page(page).per(per_page)

    # Calculate total pages before pagination
    total_pages = (total_count.to_f / per_page).ceil
    
    # If the requested page is greater than the total pages, redirect to the first page
    if page > total_pages && total_pages > 0
      # Preserve all parameters except page
      redirect_params = params.to_unsafe_h.except(:controller, :action, :page)
      redirect_params[:per_page] = per_page  # Keep the per_page parameter

      # Redirect to the first page with updated params
      return redirect_to courses_path(redirect_params)
    end

    # Get total count for pagination without loading all records
    @course_count = total_count
    
    university_buckets = search_result.response['aggregations']['unique_universities']['ids']['buckets']
    @university_course_counts = university_buckets.each_with_object({}) do |bucket, hash|
      hash[bucket['key'].to_i] = bucket['doc_count']
    end
    @all_university_ids = @university_course_counts.keys
    @university_count = @all_university_ids.size
    @available_universities = University.where(id: @all_university_ids)
   

    @university_country_counts = (search_result.response['aggregations']['unique_universities']['by_country']['buckets'] || []).each_with_object({}) do |bucket, hash|
      hash[bucket['key']] = bucket['doc_count']
    end
    @available_university_countries = @university_country_counts.keys


    @available_university_types_counts = (search_result.response['aggregations']['unique_universities']['by_type_of_university']['buckets'] || []).each_with_object({}) do |bucket, hash|
      hash[bucket['key']] = bucket['doc_count']
    end
    @available_university_types = @available_university_types_counts.keys


    # Prepare dynamic filter options based on current filtered results
    department_buckets = search_result.response['aggregations']['unique_departments']['ids']['buckets']
    @available_departments_counts = department_buckets.each_with_object({}) do |bucket, hash|
      hash[bucket['key'].to_i] = bucket['doc_count']
    end
    all_department_ids = @available_departments_counts.keys
    @available_departments = Department.where(id: all_department_ids)
   

    intake_buckets = search_result.response['aggregations']['by_intake']['buckets'] || []
    @available_intakes = intake_buckets.map { |bucket| bucket['key'] }
    @available_intakes_counts = intake_buckets.each_with_object({}) do |bucket, hash|
      hash[bucket['key']] = bucket['doc_count']
    end


    available_status_buckets = search_result.response['aggregations']['by_current_status']['buckets'] || []
    @available_statuses = available_status_buckets.map { |bucket| bucket['key'] }
    @available_statuses_counts = available_status_buckets.each_with_object({}) do |bucket, hash|
      hash[bucket['key']] = bucket['doc_count']
    end

    delivery_method_buckets = search_result.response['aggregations']['by_delivery_method']['buckets'] || []
    @available_delivery_methods = delivery_method_buckets.map { |bucket| bucket['key'] }
    @available_delivery_methods_counts = delivery_method_buckets.each_with_object({}) do |bucket, hash|
      hash[bucket['key']] = bucket['doc_count']
    end

    available_levels_buckets = search_result.response['aggregations']['by_level_of_course']['buckets'] || []
    @available_levels = available_levels_buckets.map { |bucket| bucket['key'] }
    @available_levels_counts = available_levels_buckets.each_with_object({}) do |bucket, hash|
      hash[bucket['key']] = bucket['doc_count']
    end

    allow_backlogs_buckets = search_result.response['aggregations']['by_allow_backlogs']['buckets'] || []
    @available_backlogs = allow_backlogs_buckets.map { |bucket| bucket['key'] }
    @available_backlogs_counts = allow_backlogs_buckets.each_with_object({}) do |bucket, hash|
      hash[bucket['key']] = bucket['doc_count']
    end


    lateral_entry_buckets = search_result.response.dig('aggregations', 'course_requirement', 'lateral_entry_possible', 'buckets') || []
    @available_lateral_entries = lateral_entry_buckets.map { |b| b['key'] }
    @available_lateral_entries_counts = lateral_entry_buckets.to_h do |b|
      [b['key'], b['doc_count']]
    end


    tag_buckets = search_result.response['aggregations']['tags']['by_tag']['buckets'] || []
    @available_tags_counts = tag_buckets.to_h do |bucket|
      [bucket['key'], bucket['doc_count']]
    end
    tag_ids = @available_tags_counts.keys
    @available_tags = Tag.select(:id, :tag_name).where(id: tag_ids)

    @min_application_fee = search_result.response.dig('aggregations', 'min_application_fee', 'value')
    @max_application_fee = search_result.response.dig('aggregations', 'max_application_fee', 'value')

    @min_tution_fee = search_result.response.dig('aggregations', 'min_tution_fee', 'value')
    @max_tution_fee = search_result.response.dig('aggregations', 'max_tution_fee', 'value')

    @min_duration = search_result.response.dig('aggregations', 'min_duration', 'value')
    @max_duration  = search_result.response.dig('aggregations', 'max_duration', 'value')

    @min_internship = search_result.response.dig('aggregations', 'min_internship', 'value')
    @max_internship  = search_result.response.dig('aggregations', 'max_internship', 'value')

    @min_world_ranking = search_result.response.dig('aggregations', 'unique_universities', 'min_world_ranking', 'value')
    @max_world_ranking = search_result.response.dig('aggregations', 'unique_universities', 'max_world_ranking', 'value')

    @min_national_ranking = search_result.response.dig('aggregations', 'unique_universities', 'min_national_ranking', 'value')
    @max_national_ranking = search_result.response.dig('aggregations', 'unique_universities', 'max_national_ranking', 'value')

    @min_qs_ranking = search_result.response.dig('aggregations', 'unique_universities', 'min_qs_ranking', 'value')
    @max_qs_ranking = search_result.response.dig('aggregations', 'unique_universities', 'max_qs_ranking', 'value')

    
    # Group the courses by university
    grouped_courses = @search_courses.includes(:university, :department).group_by(&:university)

    # The structure will be [{ university: university_1, courses: [course_1, course_2, ...] }]
    grouped_courses_array = grouped_courses.map do |university, courses|
      { university: university, courses: courses }
    end

    # Paginate the array using Kaminari
    @courses_by_university = Kaminari.paginate_array(grouped_courses_array, total_count: total_count)
                                     .page(page)
                                     .per(per_page)

                                     
    actual_records_on_page = @courses_by_university.size
    start_number = ((page - 1) * per_page) + 1
    end_number = [start_number + actual_records_on_page - 1, total_count].min
    @pagination_info = {
      start_number: start_number,
      end_number: end_number,
      total_courses: total_count
    }

    # Set the current currency for the view
    @current_currency = session[:currency] || 'USD'
    
    respond_to do |format|
      format.html
    end
  end

  def show
    @course = Course.find(params[:id])
    @universities = @course.universities
    @department = @course.department
    @tags = @course.tags
  end

  def search
    query = params[:query].to_s.strip
    # @courses = Course.prefix_search(query)
    @courses = Course.advanced_search(query).records
    @courses = @courses.map do |course|
      [
        course.id, 
        course.name, 
        course.university.name  # Access the university's name
      ]
    end
    respond_to do |format|
      format.json { render json: { courses: @courses } }
    end
  end
  
  def map
    @universities = University.where.not(latitude: nil, longitude: nil)
    Rails.logger.info "Found #{@universities.count} universities with coordinates"
    @universities.each do |u|
      Rails.logger.info "University: #{u.name}, Lat: #{u.latitude}, Long: #{u.longitude}"
    end
  end
end
