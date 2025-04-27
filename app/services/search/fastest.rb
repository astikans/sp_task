# This class finds the fastest path between two ports
# It inherits from Search::Base and includes RouteSearch module
# The cost_method :days is used to optimize for shortest duration
# The query:
# - Uses RoutePlanner to find optimal path
# - Orders results by departure date
# - Returns all sailings in the path
module Search
  class Fastest < Base
    # all logic is in the parent class and RouteSearch module
    include RouteSearch

    private

    def cost_method
      :days
    end
  end
end
