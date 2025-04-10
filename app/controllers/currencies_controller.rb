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
end 