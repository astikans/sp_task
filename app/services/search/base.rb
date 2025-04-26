module Search
  class Base
    def self.search(origin_port, destination_port)
      new(origin_port, destination_port).search
    end

    def initialize(origin_port, destination_port)
      @origin_port = origin_port
      @destination_port = destination_port
    end

    def search
      Formatters::Sailings.format(query)
    end

    private

    def query
      raise NotImplementedError, "Subclasses must implement the query method"
    end
  end
end
