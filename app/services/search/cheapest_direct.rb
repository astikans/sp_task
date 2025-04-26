# This class finds the cheapest direct sailing between two ports
# It inherits from Search::Base and implements the required query method
# The query:
# - Filters sailings by origin and destination ports
# - Orders by cost (in EUR) ascending
# - Returns only the cheapest result
module Search
  class CheapestDirect < Base
    private

    def query
      Sailing
        .where(origin_port: @origin_port, destination_port: @destination_port)
        .order(cost_in_eur: :asc, departure_date: :asc)
        .limit(1)
    end
  end
end