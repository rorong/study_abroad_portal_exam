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

  def exchange_rates
    rates = fetch_exchange_rates
    render json: rates
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end
  
  def set_default_currency
    session[:currency] ||= 'USD'
  end

  private

  def set_current_agency
    subdomain = request.subdomains.first
    if subdomain
      agency = Agency.find_by(subdomain: subdomain)
      if agency
        puts "-- Tenant set ------ #{agency.subdomain}"
        ActsAsTenant.current_tenant = agency
      else
        redirect_to root_url(subdomain: nil), alert: "Agency not found"
      end
    else
      # redirect_to root_url(subdomain: nil), alert: "No subdomain provided"
    end
  end

  def current_agency
    ActsAsTenant.current_tenant
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def fetch_exchange_rates
    # Try to get rates from cache first
    cached_rates = Rails.cache.read('exchange_rates')
    return cached_rates if cached_rates.present?
    
    begin
      # Try to fetch from a free exchange rate API
      response = HTTP.get('https://api.exchangerate-api.com/v4/latest/USD')
      if response.status.success?
        data = JSON.parse(response.body.to_s)
        rates = data['rates']
        
        # Extract the rates we need
        exchange_rates = {
          'USD' => 1.0,
          'CAD' => rates['CAD'],
          'INR' => rates['INR'],
          'GBP' => rates['GBP']
        }
        
        # Cache the rates for 24 hours
        Rails.cache.write('exchange_rates', exchange_rates, expires_in: 24.hours)
        
        return exchange_rates
      end
    rescue => e
      Rails.logger.error("Failed to fetch exchange rates: #{e.message}")
    end
    
    # Fallback to hardcoded rates if API fails
    {
      'USD' => 1.0,
      'CAD' => 1.37,
      'INR' => 83.12,
      'GBP' => 0.79
    }
  end
end
