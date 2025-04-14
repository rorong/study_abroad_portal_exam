module ApplicationHelper
    def departments
      Department.all
    end
  
    def intakes
      [
        "January",
        "February", 
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ]
    end
  
    def statuses
      ["Active", "Inactive"]
    end
  
    def delivery_methods
      ["Full Time", "Part Time", "Online"]
    end
  
    def tags
      Tag.all
    end
    
    def back_button(default = root_path, text = 'Back')
      link_to text, request.referer || default, class: 'btn btn-secondary'
    end

    def convert_currency(amount, from_currency = 'USD', to_currency = nil)
      return amount if amount.nil?
      to_currency ||= session[:currency] || 'USD'
      return amount if from_currency == to_currency
      # Try to get exchange rates from cache or API
      exchange_rates = fetch_exchange_rates
      
      # Check if exchange rates are valid
      if exchange_rates[from_currency].nil? || exchange_rates[to_currency].nil?
        Rails.logger.warn("Missing exchange rate for #{from_currency} or #{to_currency}")
        return amount # Return original amount if exchange rates are missing
      end
      
      # Convert to USD first if not already in USD
      usd_amount = from_currency == 'USD' ? amount : amount / exchange_rates[from_currency]
      # Then convert to target currency
      converted_amount = usd_amount * exchange_rates[to_currency]
      # Round to 2 decimal places
      converted_amount.round(2)
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
            'GBP' => rates['GBP'],
            'CAD' => rates['CAD'],
            'EUR' => rates['EUR'],
            'AED' => rates['AED'],
            'SGD' => rates['SGD'],
            'AUD' => rates['AUD'],
            'NZD' => rates['NZD'],
            'JPY' => rates['JPY'],
            'CHF' => rates['CHF'],
            'THB' => rates['THB'],
            'MYR' => rates['MYR'],
            'CNY' => rates['CNY'],
            'HKD' => rates['HKD'],
            'INR' => rates['INR']
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
        'GBP' => 0.79,
        'CAD' => 1.37,
        'EUR' => 0.92,
        'AED' => 3.67,
        'SGD' => 1.35,
        'AUD' => 1.54,
        'NZD' => 1.66,
        'JPY' => 151.50,
        'CHF' => 0.90,
        'THB' => 36.31,
        'MYR' => 4.77,
        'CNY' => 7.23,
        'HKD' => 7.82,
        'INR' => 85.12
      }
    end
    
    def format_currency(amount, currency = nil)
      return "N/A" if amount.nil?
      currency ||= session[:currency] || 'USD'
      case currency
      when 'USD'
        "$#{number_with_delimiter(amount)}"
      when 'GBP'
        "£#{number_with_delimiter(amount)}"
      when 'CAD'
        "C$#{number_with_delimiter(amount)}"
      when 'EUR'
        "€#{number_with_delimiter(amount)}"
      when 'AED'
        "د.إ#{number_with_delimiter(amount)}"
      when 'SGD'
        "S$#{number_with_delimiter(amount)}"
      when 'AUD'
        "A$#{number_with_delimiter(amount)}"
      when 'NZD'
        "NZ$#{number_with_delimiter(amount)}"
      when 'JPY'
        "¥#{number_with_delimiter(amount)}"
      when 'CHF'
        "Fr#{number_with_delimiter(amount)}"
      when 'THB'
        "฿#{number_with_delimiter(amount)}"
      when 'MYR'
        "RM#{number_with_delimiter(amount)}"
      when 'CNY'
        "¥#{number_with_delimiter(amount)}"
      when 'HKD'
        "HK$#{number_with_delimiter(amount)}"
      when 'INR'
        "₹#{number_with_delimiter(amount)}"
      else
        "$#{number_with_delimiter(amount)}"
      end
    end

end
  