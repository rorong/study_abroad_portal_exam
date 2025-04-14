class UniversitiesController < ApplicationController
  after_action :verify_authorized, except: [:map_search, :show]

  def show
    @university = University.find(params[:id])
    @courses = @university.courses.includes(:department, :tags)
                        .page(params[:page])
                        .per(6)
  end

  def map_search
    # Only get universities that have valid coordinates
    @universities = University.where.not(latitude: nil, longitude: nil)
    
    # If university_ids are provided (from course search results), filter by those IDs
    if params[:university_ids].present?
      university_ids = params[:university_ids].split(',').map(&:to_i)
      @universities = @universities.where(id: university_ids)
    end
    
    # Apply location-based search if coordinates are provided
    if params[:lat].present? && params[:lng].present? && params[:query].present?
      lat = params[:lat].to_f
      lng = params[:lng].to_f
      radius_km = 50 # 50km radius
      
      # Using Haversine formula for distance calculation
      distance_formula = "(6371 * acos(cos(radians(#{ActiveRecord::Base.connection.quote(lat)})) * " \
                        "cos(radians(latitude)) * " \
                        "cos(radians(longitude) - radians(#{ActiveRecord::Base.connection.quote(lng)})) + " \
                        "sin(radians(#{ActiveRecord::Base.connection.quote(lat)})) * " \
                        "sin(radians(latitude))))"

      @universities = @universities
        .select("universities.*, #{distance_formula} as distance")
        .where("#{distance_formula} <= ?", radius_km)
        .order('distance')
    else
      # Show all universities by default, ordered by name
      @universities = @universities.order(:name)
    end

    respond_to do |format|
      format.html
      format.json { 
        render json: {
          universities: @universities.as_json(
            only: [:id, :name, :latitude, :longitude, :country, :city, :address, :type_of_university, :world_ranking, :qs_ranking]
          ),
          total_count: @universities.size
        }
      }
    end
  end
end 