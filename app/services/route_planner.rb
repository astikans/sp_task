# This class finds the optimal path between two points using a modified Dijkstra's algorithm
# It is a generic implementation that can work with any objects that have:
# - A cost method (specified in mapping[:object_method_cost])
# - A point A method (specified in mapping[:object_method_point_a])
# - A point Z method (specified in mapping[:object_method_point_z])
# - A start date method (specified in mapping[:object_method_start_date])
# - An end date method (specified in mapping[:object_method_end_date])
#
# @param objects [ActiveRecord::Relation] Collection of objects to search through
# @param point_a [Integer] ID of the starting point
# @param point_z [Integer] ID of the ending point
# @param start_date [Date] Earliest allowed start date
# @param mapping [Hash] Methods to use for accessing object attributes
# @return [Array<Integer>] Array of object IDs representing the optimal path

class RoutePlanner
  class InvalidInputError < StandardError; end

  def self.call(...)
    new(...).call
  end

  def initialize(objects:, point_a:, point_z:, start_date:, mapping: {})
    @objects = objects
    @point_a = point_a
    @point_z = point_z
    @start_date = start_date
    set_objects_from_mapping(mapping)
  end

  def call
    raise InvalidInputError, "Invalid inputs" unless valid_inputs?

    find_cheapest_path
  end

  private

  def set_objects_from_mapping(mapping)
    @object_method_cost = mapping[:object_method_cost]
    @object_method_point_a = mapping[:object_method_point_a]
    @object_method_point_z = mapping[:object_method_point_z]
    @object_method_start_date = mapping[:object_method_start_date]
    @object_method_end_date = mapping[:object_method_end_date]
  end

  def valid_inputs?
    [
      @objects, @point_a, @point_z, @start_date,
      @object_method_cost, @object_method_point_a, @object_method_point_z,
      @object_method_start_date, @object_method_end_date
    ].all?(&:present?)
  end

  def objects_by_origin
    @objects_by_origin ||= @objects.group_by(&@object_method_point_a)
  end

  def find_cheapest_path
    queue = initialized_and_sorted_queue || []
    visited = Set.new
    best_path = []
    min_cost = Float::INFINITY

    until queue.empty?
      cost, current_object, path = queue.shift

      # Skip if already visited this state
      state_key = [current_object.send(@object_method_start_date), current_object.send(@object_method_end_date)]
      next if visited.include?(state_key)

      visited << state_key

      # Check if we reached the destination
      if destination_reached?(current_object, cost, min_cost)
        best_path = path
        min_cost = cost
        next
      end

      # Explore next possible objects
      explore_next_objects(queue, current_object, cost, path)
    end

    best_path.map(&:id)
  end

  def initialize_queue
    objects_by_origin[@point_a]&.each_with_object([]) do |object, queue|
      next if object.send(@object_method_start_date) < @start_date
      queue << [object.send(@object_method_cost), object, [object]]
    end || []
  end

  def initialized_and_sorted_queue
    initialize_queue.sort_by! { |cost, *_| cost }
  end

  def destination_reached?(object, cost, min_cost)
    object.send(@object_method_point_z) == @point_z && cost < min_cost
  end

  def explore_next_objects(queue, current_object, current_cost, current_path)
    next_objects = objects_by_origin[current_object.send(@object_method_point_z)]

    next_objects&.each do |next_object|
      if next_object.send(@object_method_start_date) >= current_object.send(@object_method_end_date)
        queue << [
          current_cost + next_object.send(@object_method_cost),
          next_object,
          current_path + [next_object]
        ]
      end
    end
  end
end