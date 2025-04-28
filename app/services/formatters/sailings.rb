# This class formats sailing records into a standardized hash format
# It includes related port and rate information for each sailing
# The format method takes a collection of sailings and returns an array of formatted hashes
# Each hash contains:
# - origin_port: the code of the departure port
# - destination_port: the code of the arrival port
# - departure_date: the date the sailing leaves
# - arrival_date: the date the sailing arrives
# - sailing_code: the code of the associated sailing rate
# - rate: the price of the sailing
# - rate_currency: the currency the rate is in
module Formatters
  class Sailings
    def self.format(sailings)
      # Use includes to avoid N+1 queries when accessing associated records
      # Without includes, each iteration would trigger separate DB queries for:
      # - origin_port
      # - destination_port
      # - sailing_rate
      sailings.includes(:origin_port, :destination_port, :sailing_rate).map do |sailing|
        {
          "origin_port" => sailing.origin_port.code,
          "destination_port" => sailing.destination_port.code,
          "departure_date" => sailing.departure_date.to_s,
          "arrival_date" => sailing.arrival_date.to_s,
          "sailing_code" => sailing.sailing_rate.code,
          "rate" => sailing.sailing_rate.rate.to_s,
          "rate_currency" => sailing.sailing_rate.rate_currency
        }
      end
    end
  end
end
