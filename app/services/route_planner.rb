class RoutePlanner
  class InvalidInputError < StandardError; end

  def self.call(...)
    new(...).call
  end

  def initialize(sailings:, cost_method:, origin_port:, destination_port:, start_date:)
    @sailings = sailings
    @cost_method = cost_method
    @origin_port = origin_port
    @destination_port = destination_port
    @start_date = start_date
  end

  def call
    raise InvalidInputError, "Invalid inputs" unless valid_inputs?

    find_cheapest_path
  end

  private

  def valid_inputs?
    [@sailings, @cost_method, @origin_port, @destination_port, @start_date].all?(&:present?)
  end

  def sailings_by_origin
    @sailings_by_origin ||= @sailings.group_by(&:origin_port_id)
  end

  def find_cheapest_path
    queue = initialized_and_sorted_queue || []
    visited = Set.new
    best_path = []
    min_cost = Float::INFINITY

    until queue.empty?
      cost, current_sailing, path = queue.shift

      # Skip if already visited this state
      state_key = [current_sailing.departure_date, current_sailing.arrival_date]
      next if visited.include?(state_key)

      visited << state_key

      # Check if we reached the destination
      if destination_reached?(current_sailing, cost, min_cost)
        best_path = path
        min_cost = cost
        next
      end

      # Explore next possible sailings
      explore_next_sailings(queue, current_sailing, cost, path)
    end

    best_path.map(&:id)
  end

  def initialize_queue
    sailings_by_origin[@origin_port.id]&.each_with_object([]) do |sailing, queue|
      next if sailing.departure_date < @start_date
      queue << [sailing.send(@cost_method), sailing, [sailing]]
    end || []
  end

  def initialized_and_sorted_queue
    initialize_queue.sort_by! { |cost, *_| cost }
  end

  def destination_reached?(sailing, cost, min_cost)
    sailing.destination_port_id == @destination_port.id && cost < min_cost
  end

  def explore_next_sailings(queue, current_sailing, current_cost, current_path)
    next_sailings = sailings_by_origin[current_sailing.destination_port_id]

    next_sailings&.each do |next_sailing|
      if next_sailing.departure_date >= current_sailing.arrival_date
        queue << [
          current_cost + next_sailing.send(@cost_method),
          next_sailing,
          current_path + [next_sailing]
        ]
      end
    end
  end
end