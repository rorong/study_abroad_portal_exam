class CoursesController < ApplicationController
  def search_page
    # This is the new landing page with just the search bar
  end

  def index
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

    # Extract the course IDs
    course_buckets = search_result.response['aggregations']['unique_courses']['buckets'] || []
    @all_course_ids = course_buckets.map { |bucket| bucket['key'] }
    # all_course_count = all_course_ids.size
    @filtered_courses_query = Course.where(id: @all_course_ids)
    
    # Convert Elasticsearch hits to ActiveRecord models
    @search_courses = search_result.records

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
    @all_university_ids = university_buckets.map { |bucket| bucket['key'] }
    @university_count = @all_university_ids.size
    @available_universities = University.where(id: @all_university_ids)

    @available_university_countries = @available_universities.pluck(:country).compact.uniq
    @university_course_counts = @filtered_courses_query.joins(:universities).group('universities.id').count
    @university_country_counts = @filtered_courses_query.joins(:universities).group('universities.country').count


    @available_university_types = @available_universities.pluck(:type_of_university).compact.uniq
    @available_university_types_counts = @filtered_courses_query.joins(:universities).group('universities.type_of_university').count

    # Prepare dynamic filter options based on current filtered results
    department_buckets = search_result.response['aggregations']['unique_departments']['ids']['buckets']
    all_department_ids = department_buckets.map { |bucket| bucket['key'] }
    @available_departments = Department.where(id: all_department_ids)

    @available_departments_counts = @filtered_courses_query.joins(:department).group('departments.id').count

    @available_intakes = @filtered_courses_query.pluck(:intake).compact.uniq
    @available_intakes_counts = @filtered_courses_query.group('intake').count

    @available_statuses = @filtered_courses_query.pluck(:current_status).compact.uniq
    @available_statuses_counts = @filtered_courses_query.group('current_status').count

    @available_delivery_methods = @filtered_courses_query.pluck(:delivery_method).compact.uniq
    @available_delivery_methods_counts = @filtered_courses_query.group('delivery_method').count

    @available_levels = @filtered_courses_query.pluck(:level_of_course).compact.uniq
    @available_levels_counts = @filtered_courses_query.group('level_of_course').count

    @available_backlogs = @filtered_courses_query.pluck(:allow_backlogs).compact.uniq
    @available_backlogs_counts = @filtered_courses_query.group('allow_backlogs').count


    @available_lateral_entries = @filtered_courses_query.joins(:course_requirement).distinct.pluck('course_requirements.lateral_entry_possible').compact.uniq
    @available_lateral_entries_counts = @filtered_courses_query.joins(:course_requirement).group('course_requirements.lateral_entry_possible').count

    @available_tags = @filtered_courses_query.joins(:tags).where.not(tags: { tag_name: nil }).select('tags.id, tags.tag_name').distinct
    @available_tags_counts = @filtered_courses_query.joins(:tags).group('tags.id').count

    # Group the courses by university
    grouped_courses = @search_courses.includes(:university, :department).group_by(&:university)

    # Paginate the array using Kaminari
    @courses_by_university = Kaminari.paginate_array(grouped_courses.to_a, total_count: total_count)
                                     .page(page)
                                     .per(per_page)
               

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
    @courses = Course.prefix_search(query)
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
