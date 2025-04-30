module CurrencyHelper
      def convert_currency(amount, from_currency = 'USD', to_currency = nil)
        return amount if amount.nil?
        to_currency ||= session[:currency] || 'USD'
        return amount if from_currency == to_currency

        exchange_rates = fetch_exchange_rates

        from_rate = exchange_rates[from_currency]
        to_rate = exchange_rates[to_currency]

        # Defensive: Convert both rates to Float safely
        from_rate = from_rate.to_s.gsub(/[^\d\.]/, '').to_f
        to_rate = to_rate.to_s.gsub(/[^\d\.]/, '').to_f

        if from_rate.zero? || to_rate.zero?
          Rails.logger.warn("Invalid exchange rate: #{from_currency}=#{from_rate}, #{to_currency}=#{to_rate}")
          return amount
        end

        usd_amount = from_currency == 'USD' ? amount.to_f : amount.to_f / from_rate
        converted_amount = usd_amount * to_rate
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
      
      def currency_symbol(currency = nil)
        currency ||= session[:currency] || 'USD'
        {
          'USD' => '$', 'GBP' => '£', 'EUR' => '€', 'AED' => 'د.إ', 'SGD' => 'S$', 'AUD' => 'A$',
          'NZD' => 'NZ$', 'JPY' => '¥', 'CHF' => 'Fr', 'THB' => '฿', 'MYR' => 'RM',
          'CNY' => '¥', 'HKD' => 'HK$', 'CAD' => 'C$', 'INR' => '₹'
        }[currency] || '$'
      end
      
end
