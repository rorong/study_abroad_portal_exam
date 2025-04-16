class CurrenciesController < ApplicationController
  def set_currency
    currency = params[:currency]
    
    # Validate currency against the full list
    valid_currencies = ['USD', 'GBP', 'CAD', 'EUR', 'AED', 'SGD', 'AUD', 'NZD', 'JPY', 'CHF', 'THB', 'MYR', 'CNY', 'HKD', 'INR']
    
    if valid_currencies.include?(currency)
      session[:currency] = currency
      # Clear any cached exchange rates to force a refresh
      Rails.cache.delete('exchange_rates')
      # Clear any cached course currency displays
      Rails.cache.delete_matched("views/courses/*")
      # No need to call session.save as Rails handles this automatically
    end
    
    # Redirect back to the previous page with a refresh parameter
    # Use a full page reload instead of Turbo
    redirect_to request.referer || root_path, notice: "Currency updated to #{currency}", allow_other_host: false
  end
    def exchange_rates
    rates = fetch_exchange_rates
    render json: rates
  end
  private
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