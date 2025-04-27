# This class finds the cheapest path between two ports
# It inherits from Search::Base and includes RouteSearch module
# The cost_method :cost_in_eur is used to optimize for lowest cost
# The query:
# - Uses RoutePlanner to find optimal path
# - Orders results by departure date
# - Returns all sailings in the path
module Search
  class Cheapest < Base
    # all logic is in the parent class and RouteSearch module
    include RouteSearch

    private

    def cost_method
      :cost_in_eur
    end
  end
end
