# Imports data from a JSON data structure into the database.
#
# @param json_data [Hash] The parsed JSON data containing exchange rates, sailing rates, and sailings
# @return [void]
#
# Example JSON structure:
# {
#   "exchange_rates": {
#     "2025-01-01": {"usd": 1.1, "jpy": 149.93},
#     "2025-01-02": {"usd": 1.2, "jpy": 145.06}
#   },
#   "rates": [
#     {
#       "sailing_code": "ETRG",
#       "rate": "100.00",
#       "rate_currency": "USD"
#     }
#   ],
#   "sailings": [
#     {
#       "origin_port": "NLRTM",
#       "destination_port": "ESBCN",
#       "departure_date": "2025-01-01",
#       "arrival_date": "2025-01-10",
#       "sailing_code": "ETRG"
#     }
#   ]
# }

class DataImporter
  def self.call(json_data)
    new(json_data).call
  end

  def initialize(json_data)
    @json_data = json_data
  end

  def call
    ActiveRecord::Base.transaction do
      import_exchange_rates
      import_sailing_rates
      import_sailings_and_ports
    end
  end

  private

  def import_exchange_rates
    @json_data["exchange_rates"].each do |date, rates|
      ExchangeRate.find_or_create_by!(date: date, rates: rates)
    end
  end

  def import_sailing_rates
    @json_data["rates"].each do |sailing_rate|
      SailingRate.find_or_create_by!(
        code: sailing_rate["sailing_code"],
        rate: sailing_rate["rate"].to_f,
        rate_currency: sailing_rate["rate_currency"]
      )
    end
  end

  def import_sailings_and_ports
    @json_data["sailings"].each do |sailing|
      Sailing.find_or_create_by!(
        {
          **port_params(sailing["origin_port"], sailing["destination_port"]),
          **date_params(sailing["departure_date"], sailing["arrival_date"]),
          **sailing_rate_params(sailing["sailing_code"], sailing["departure_date"]),
        }
      )
    end
  end

  def port_params(origin_port, destination_port)
    {
      origin_port: find_or_create_port(origin_port),
      destination_port: find_or_create_port(destination_port),
    }
  end

  def date_params(departure_date, arrival_date)
    {
      departure_date: departure_date,
      arrival_date: arrival_date,
      days: (arrival_date.to_date - departure_date.to_date).to_i,
    }
  end

  def sailing_rate_params(sailing_code, departure_date)
    sailing_rate = lookup_sailing_rate(sailing_code)

    {
      sailing_rate: sailing_rate,
      cost_in_eur: cost_in_eur(sailing_rate, departure_date)
    }
  end

  def find_or_create_port(code)
    Port.find_or_create_by!(code: code)
  end

  def lookup_sailing_rate(sailing_code)
    SailingRate.find_by(code: sailing_code)
  end

  def exchange_rate_for(date, currency)
    ExchangeRate.find_by(date: date).rates[currency.downcase]
  end

  def cost_in_eur(sailing_rate, date)
    return sailing_rate.rate if sailing_rate.eur?

    # convert to eur
    sailing_rate.rate / exchange_rate_for(date, sailing_rate.rate_currency)
  end

end
