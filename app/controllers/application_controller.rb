class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  include Pundit::Authorization
  
  before_action :set_current_agency
  # Prevent CSRF attacks by raising an exception
  protect_from_forgery with: :exception

  # Authenticate user with Devise
  before_action :authenticate_user!

  # Rescue from Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # Set default currency if not set
  before_action :set_default_currency

  helper_method :current_agency

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end
  
  def set_default_currency
    session[:currency] ||= 'USD'
  end

  private

  def set_current_agency
    agency = Agency.first
    ActsAsTenant.current_tenant = agency
    
    # subdomain = request.subdomains.first

    # if subdomain
    #   if agency
    #     puts "-- Tenant set ------ #{agency.subdomain}"
    #     ActsAsTenant.current_tenant = agency
    #   else
    #     raise ActsAsTenant::Errors::NoTenantSet unless agency
    #     # redirect_to root_url(subdomain: nil), alert: "Agency not found"
    #   end
    # else
    #   raise ActsAsTenant::Errors::NoTenantSet unless agency
    #   # redirect_to root_url(subdomain: nil), alert: "No subdomain provided"
    # end
  end

  def current_agency
    ActsAsTenant.current_tenant
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

end
