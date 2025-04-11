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

    @courses = Course.advanced_search(params[:query]).records
    
    # Get total count for pagination without loading all records
    @course_count = @courses.count
    # Get total unique universities count before pagination
    @university_count = @courses.joins(:universities).select('universities.id').distinct.count
    
    # Store all university IDs before pagination for the map view
    @all_university_ids = @courses.joins(:universities).select('universities.id').distinct.pluck('universities.id')
    
    # Calculate filter options from the total filtered results before pagination
    filtered_course_ids = @courses.pluck(:id)
    
    # Store the filtered query before pagination for filter counts
    @filtered_courses_query = @courses
    
    # Prepare dynamic filter options based on current filtered results
    @available_institutions = University.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_departments = Department.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_universities = University.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_university_countries = University.joins(:courses).where(courses: { id: filtered_course_ids }).distinct.pluck(:country).compact
    @available_university_types = University.joins(:courses).where(courses: { id: filtered_course_ids }).distinct.pluck(:type_of_university).compact
    @available_intakes = Course.where(id: filtered_course_ids).distinct.pluck(:intake).compact
    @available_statuses = Course.where(id: filtered_course_ids).distinct.pluck(:current_status).compact
    @available_delivery_methods = Course.where(id: filtered_course_ids).distinct.pluck(:delivery_method).compact
    @available_durations = Course.where(id: filtered_course_ids).distinct.pluck(:course_duration).compact
    @available_levels = Course.where(id: filtered_course_ids).distinct.pluck(:level_of_course).compact
    @available_application_fees = Course.where(id: filtered_course_ids).distinct.pluck(:application_fee).compact
    @available_backlogs = Course.where(id: filtered_course_ids).distinct.pluck(:allow_backlogs).compact
    @available_lateral_entries = Course.joins(:course_requirement).where(id: filtered_course_ids).distinct.pluck('course_requirements.lateral_entry_possible').compact
    @available_tags = Tag.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_education_boards = EducationBoard.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_internship_periods = Course.where(id: filtered_course_ids).distinct.pluck(:internship_period).compact
    
    # Get per_page parameter from request or use default
    per_page = params[:per_page].present? ? params[:per_page].to_i : 15
    # Ensure per_page is within reasonable limits
    per_page = [per_page, 5, 10, 15, 25, 50, 100].include?(per_page) ? per_page : 15
    
    # Calculate total pages before pagination
    total_pages = (@courses.count.to_f / per_page).ceil
    
    # If the requested page is greater than the total pages, redirect to the first page
    if params[:page].present? && params[:page].to_i > total_pages && total_pages > 0
      # Preserve all parameters except page
      redirect_params = params.to_unsafe_h.except(:controller, :action, :page)
      redirect_params[:per_page] = per_page
      return redirect_to courses_path(redirect_params)
    end
    
    # Apply pagination after calculating filter counts
    @courses = @courses.page(params[:page]).per(per_page)

    #Refactor later
    if params[:query].present?
      @filtered_courses = @courses.includes(:university).where(id: @courses.pluck(:id))
      @courses_by_university = @filtered_courses.group_by(&:university)

    else
      @courses_by_university = @courses.joins(:universities).group_by { |course| course.universities.first }.reject { |_, courses| courses.empty? }
    end
    
    # Set the current currency for the view
    @current_currency = session[:currency] || 'USD'
    
    respond_to do |format|
      format.html
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace(
          "courses_list",
          partial: "courses_list",
          locals: {
            courses: @courses,
            courses_by_university: @courses_by_university,
            subjects: @subjects,
            tests: @tests,
            institutions: @available_institutions,
            departments: @available_departments,
            tags: @available_tags,
            universities: @available_universities,
            available_backlogs: @available_backlogs,
            available_lateral_entries: @available_lateral_entries,
            available_internship_periods: @available_internship_periods,
            per_page: per_page,
            filtered_courses_query: @filtered_courses_query
          }
        )
      }
    end
  end


  def index_old
    # Initialize base query with eager loading to reduce N+1 queries
    @courses = Course.includes(:universities, :institution, :department, :tags, :education_board)

    # Store the search results separately
    search_results = nil
    if params[:query].present?
      # Limit initial search results to improve performance
      results = Course.search_courses_and_subjects(params[:query], limit: 200)
      @courses_by_university = results[:courses_by_university]
      @subjects = results[:subjects]
      @tests = results[:tests]
      search_results = results[:courses_by_university].values.flatten.map(&:id)
      @courses = @courses.where(id: search_results)
    else
      @courses_by_university = {}
      @subjects = []
      @tests = []
    end

    # Apply filters only if they exist in the params
    @courses = @courses.where(intake: params[:intake]) if params[:intake].present?
    @courses = @courses.where(current_status: params[:current_status]) if params[:current_status].present?
    @courses = @courses.where('title LIKE ?', "%#{params[:title]}%") if params[:title].present?
    @courses = @courses.where(delivery_method: params[:delivery_method]) if params[:delivery_method].present?
    @courses = @courses.where(institution_id: params[:institution_id]) if params[:institution_id].present?
    @courses = @courses.where(department_id: params[:department_id]) if params[:department_id].present?
    @courses = @courses.joins(:tags).where(tags: { id: params[:tag_id] }) if params[:tag_id].present?
    @courses = @courses.where(allow_backlogs: params[:allow_backlogs]) if params[:allow_backlogs].present?

    
    
    @courses = @courses.joins(:course_requirement).where(course_requirements: { lateral_entry_possible: params[:lateral_entry_possible] }) if params[:lateral_entry_possible].present?
    
    @courses = @courses.joins(:universities).where(universities: { type_of_university: params[:type_of_university] }) if params[:type_of_university].present?
    
    # Handle distance-based filtering
    if params[:latitude].present? && params[:longitude].present?
      lat = params[:latitude].to_f
      lng = params[:longitude].to_f
      distance = params[:distance].present? ? params[:distance].to_f : 50 # Use the distance parameter or default to 50 km
      
      # Using Haversine formula for distance calculation
      distance_formula = "(6371 * acos(cos(radians(#{ActiveRecord::Base.connection.quote(lat)})) * " \
                        "cos(radians(universities.latitude)) * " \
                        "cos(radians(universities.longitude) - radians(#{ActiveRecord::Base.connection.quote(lng)})) + " \
                        "sin(radians(#{ActiveRecord::Base.connection.quote(lat)})) * " \
                        "sin(radians(universities.latitude))))"

      # Apply the distance filter
      @courses = @courses
        .joins(:universities)
        .where("#{distance_formula} <= ?", distance)
    end
    
    # Handle course duration range
    if params[:min_duration].present? || params[:max_duration].present?
      min_duration = params[:min_duration].present? ? params[:min_duration].to_i : 0
      max_duration = params[:max_duration].present? ? params[:max_duration].to_i : Float::INFINITY
      @courses = @courses.where(course_duration: min_duration..max_duration)
    end
    
    # @courses = @courses.where(education_board_id: params[:education_board_id]) if params[:education_board_id].present?
    @courses = @courses.where(level_of_course: params[:level_of_course]) if params[:level_of_course].present? 
    
    # Handle internship period range
    if params[:min_internship].present? || params[:max_internship].present?
      min_internship = params[:min_internship].present? ? params[:min_internship].to_i : 0
      max_internship = params[:max_internship].present? ? params[:max_internship].to_i : Float::INFINITY
      @courses = @courses.where(internship_period: min_internship..max_internship)
    end
    
    # Handle application fee range
    if params[:min_application_fee].present? || params[:max_application_fee].present?
      min_fee = params[:min_application_fee].present? ? params[:min_application_fee].to_f : 0
      max_fee = params[:max_application_fee].present? ? params[:max_application_fee].to_f : Float::INFINITY
      @courses = @courses.where(application_fee: min_fee..max_fee)
    end
    
    @courses = @courses.joins(:universities).where(universities: { id: params[:university_id] }) if params[:university_id].present?
    @courses = @courses.joins(:universities).where(universities: { country: params[:university_country] }) if params[:university_country].present?
    @courses = @courses.joins(:universities).where('universities.address LIKE ?', "%#{params[:university_address]}%") if params[:university_address].present? && !params[:latitude].present?
    
    # Add ranking filters
    if params[:min_world_ranking].present? || params[:max_world_ranking].present?
      min_rank = params[:min_world_ranking].present? ? params[:min_world_ranking].to_i : 0
      max_rank = params[:max_world_ranking].present? ? params[:max_world_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities).where(universities: { world_ranking: min_rank..max_rank })
    end
    
    if params[:min_qs_ranking].present? || params[:max_qs_ranking].present?
      min_rank = params[:min_qs_ranking].present? ? params[:min_qs_ranking].to_i : 0
      max_rank = params[:max_qs_ranking].present? ? params[:max_qs_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities).where(universities: { qs_ranking: min_rank..max_rank })
    end
    
    if params[:min_national_ranking].present? || params[:max_national_ranking].present?
      min_rank = params[:min_national_ranking].present? ? params[:min_national_ranking].to_i : 0
      max_rank = params[:max_national_ranking].present? ? params[:max_national_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities).where(universities: { national_ranking: min_rank..max_rank })
    end
    
    # Handle tuition fee range
    if params[:min_tuition_fee].present? || params[:max_tuition_fee].present?
      min_fee = params[:min_tuition_fee].present? ? params[:min_tuition_fee].to_f : 0
      max_fee = params[:max_tuition_fee].present? ? params[:max_tuition_fee].to_f : Float::INFINITY
      @courses = @courses.where(tuition_fee_international: min_fee..max_fee)
    end

    # Apply sorting if specified
    if params[:sort].present?
      case params[:sort]
      when 'application_fee_asc'
        if params[:query].present?
          sorted_courses = @courses_by_university.values.flatten.sort_by { |course| course.application_fee || Float::INFINITY }
          @courses_by_university = sorted_courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
          @courses = Course.includes(:universities, :institution, :department, :tags, :education_board)
                         .where(id: sorted_courses.map(&:id))
        else
          @courses = @courses.order(application_fee: :asc)
          @courses_by_university = @courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
        end
      when 'application_fee_desc'
        if params[:query].present?
          sorted_courses = @courses_by_university.values.flatten.sort_by { |course| course.application_fee || Float::INFINITY }.reverse
          @courses_by_university = sorted_courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
          @courses = Course.includes(:universities, :institution, :department, :tags, :education_board)
                         .where(id: sorted_courses.map(&:id))
        else
          @courses = @courses.order(application_fee: :desc)
          @courses_by_university = @courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
        end
      when 'tuition_fee_asc'
        if params[:query].present?
          sorted_courses = @courses_by_university.values.flatten.sort_by { |course| course.tuition_fee_international || Float::INFINITY }
          @courses_by_university = sorted_courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
          @courses = Course.includes(:universities, :institution, :department, :tags, :education_board)
                         .where(id: sorted_courses.map(&:id))
        else
          @courses = @courses.order(tuition_fee_international: :asc)
          @courses_by_university = @courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
        end
      when 'tuition_fee_desc'
        if params[:query].present?
          sorted_courses = @courses_by_university.values.flatten.sort_by { |course| course.tuition_fee_international || Float::INFINITY }.reverse
          @courses_by_university = sorted_courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
          @courses = Course.includes(:universities, :institution, :department, :tags, :education_board)
                         .where(id: sorted_courses.map(&:id))
        else
          @courses = @courses.order(tuition_fee_international: :desc)
          @courses_by_university = @courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
        end
      when 'course_duration_asc'
        if params[:query].present?
          sorted_courses = @courses_by_university.values.flatten.sort_by { |course| course.course_duration.to_i }
          @courses_by_university = sorted_courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
          @courses = Course.includes(:universities, :institution, :department, :tags, :education_board)
                         .where(id: sorted_courses.map(&:id))
        else
          @courses = @courses.order(course_duration: :asc)
          @courses_by_university = @courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
        end
      when 'course_duration_desc'
        if params[:query].present?
          sorted_courses = @courses_by_university.values.flatten.sort_by { |course| course.course_duration.to_i }.reverse
          @courses_by_university = sorted_courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
          @courses = Course.includes(:universities, :institution, :department, :tags, :education_board)
                         .where(id: sorted_courses.map(&:id))
        else
          @courses = @courses.order(course_duration: :desc)
          @courses_by_university = @courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
        end
      end
    elsif !params[:query].present?
      @courses_by_university = @courses.select { |course| course.universities.any? }.group_by { |course| course.universities.first }
    end

    # Get total count for pagination without loading all records
    @course_count = @courses.count
    # Get total unique universities count before pagination
    @university_count = @courses.joins(:universities).select('universities.id').distinct.count
    
    # Store all university IDs before pagination for the map view
    @all_university_ids = @courses.joins(:universities).select('universities.id').distinct.pluck('universities.id')
    
    # Calculate filter options from the total filtered results before pagination
    filtered_course_ids = @courses.pluck(:id)
    
    # Store the filtered query before pagination for filter counts
    @filtered_courses_query = @courses
    
    # Prepare dynamic filter options based on current filtered results
    @available_institutions = Institution.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_departments = Department.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_universities = University.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_university_countries = University.joins(:courses).where(courses: { id: filtered_course_ids }).distinct.pluck(:country).compact
    @available_university_types = University.joins(:courses).where(courses: { id: filtered_course_ids }).distinct.pluck(:type_of_university).compact
    @available_intakes = Course.where(id: filtered_course_ids).distinct.pluck(:intake).compact
    @available_statuses = Course.where(id: filtered_course_ids).distinct.pluck(:current_status).compact
    @available_delivery_methods = Course.where(id: filtered_course_ids).distinct.pluck(:delivery_method).compact
    @available_durations = Course.where(id: filtered_course_ids).distinct.pluck(:course_duration).compact
    @available_levels = Course.where(id: filtered_course_ids).distinct.pluck(:level_of_course).compact
    @available_application_fees = Course.where(id: filtered_course_ids).distinct.pluck(:application_fee).compact
    @available_backlogs = Course.where(id: filtered_course_ids).distinct.pluck(:allow_backlogs).compact
    @available_lateral_entries = Course.joins(:course_requirement).where(id: filtered_course_ids).distinct.pluck('course_requirements.lateral_entry_possible').compact
    @available_tags = Tag.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_education_boards = EducationBoard.joins(:courses).where(courses: { id: filtered_course_ids }).distinct
    @available_internship_periods = Course.where(id: filtered_course_ids).distinct.pluck(:internship_period).compact
    
    # Get per_page parameter from request or use default
    per_page = params[:per_page].present? ? params[:per_page].to_i : 15
    # Ensure per_page is within reasonable limits
    per_page = [per_page, 5, 10, 15, 25, 50, 100].include?(per_page) ? per_page : 15
    
    # Calculate total pages before pagination
    total_pages = (@courses.count.to_f / per_page).ceil
    
    # If the requested page is greater than the total pages, redirect to the first page
    if params[:page].present? && params[:page].to_i > total_pages && total_pages > 0
      # Preserve all parameters except page
      redirect_params = params.to_unsafe_h.except(:controller, :action, :page)
      redirect_params[:per_page] = per_page
      return redirect_to courses_path(redirect_params)
    end
    
    # Apply pagination after calculating filter counts
    @courses = @courses.page(params[:page]).per(per_page)

    if params[:query].present?
      filtered_course_ids = @courses.pluck(:id)
      @courses_by_university = @courses_by_university.transform_values do |courses|
        courses.select { |course| filtered_course_ids.include?(course.id) }
      end.reject { |_, courses| courses.empty? }
    else
      @courses_by_university = @courses.joins(:universities).group_by { |course| course.universities.first }.reject { |_, courses| courses.empty? }
    end
    
    # Set the current currency for the view
    @current_currency = session[:currency] || 'USD'
    
    respond_to do |format|
      format.html
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace(
          "courses_list",
          partial: "courses_list",
          locals: {
            courses: @courses,
            courses_by_university: @courses_by_university,
            subjects: @subjects,
            tests: @tests,
            institutions: @available_institutions,
            departments: @available_departments,
            tags: @available_tags,
            universities: @available_universities,
            available_backlogs: @available_backlogs,
            available_lateral_entries: @available_lateral_entries,
            available_internship_periods: @available_internship_periods,
            per_page: per_page,
            filtered_courses_query: @filtered_courses_query
          }
        )
      }
    end
  end

  def show
    @course = Course.find(params[:id])
    @universities = @course.universities
    @institution = @course.institution
    @department = @course.department
    @tags = @course.tags
    @education_board = @course.education_board
  end

  def search
    query = params[:query].to_s.strip
    Rails.logger.info "Search query: #{query}"
    
    if query.present?
      # Limit search results to improve performance
      @courses = Course.joins(:universities)
                      .where("courses.name ILIKE ? OR universities.name ILIKE ?", "%#{query}%", "%#{query}%")
                      .select("courses.id, courses.name as name, universities.name as university_name")
                      .limit(10)
                      .map { |course| [course.id, course.name, course.university_name] }
      Rails.logger.info "Found #{@courses.size} results"
    else
      @courses = []
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
