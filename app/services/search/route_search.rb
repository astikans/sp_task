module Search
  module RouteSearch
    private

    def query
      return Sailing.none unless sailings.any?

      Sailing.where(id: sailing_ids).order(:departure_date)
    end

    def sailing_ids
      RoutePlanner.call(
        objects: sailings,
        point_a: @origin_port.id,
        point_z: @destination_port.id,
        start_date: start_date,
        mapping: mapping
      )
    end

    def sailings
      @sailings ||= Sailing.all
    end

    def start_date
      @start_date ||= sailings.minimum(:departure_date)
    end

    def mapping
      {
        object_method_cost: cost_method, # set in class where this is included
        object_method_point_a: :origin_port_id,
        object_method_point_z: :destination_port_id,
        object_method_start_date: :departure_date,
        object_method_end_date: :arrival_date
      }
    end
  end
end