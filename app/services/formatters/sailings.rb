module Formatters
  class Sailings
    def self.format(sailings)
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
