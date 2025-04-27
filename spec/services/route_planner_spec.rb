require 'rails_helper'

RSpec.describe RoutePlanner do
  # TestObject class for testing with non-Sailing objects
  class TestObject
    attr_reader :id, :source, :destination, :start_time, :end_time, :price

    def initialize(id:, source:, destination:, start_time:, end_time:, price:)
      @id = id
      @source = source
      @destination = destination
      @start_time = start_time
      @end_time = end_time
      @price = price
    end
  end

  describe '.call' do
    let(:origin_port) { create(:port, code: 'NLRTM') }
    let(:destination_port) { create(:port, code: 'ESBCN') }
    let(:sailing_rate) { create(:sailing_rate, code: 'RATE1', rate: 100.00, rate_currency: 'EUR') }
    let(:start_date) { Date.new(2025, 6, 1) }

    let(:sailing1) do
      create(:sailing,
        origin_port: origin_port,
        destination_port: destination_port,
        departure_date: Date.new(2025, 6, 5),
        arrival_date: Date.new(2025, 6, 10),
        days: 5,
        cost_in_eur: 500.00,
        sailing_rate: sailing_rate
      )
    end

    let(:mapping) do
      {
        object_method_cost: :cost_in_eur,
        object_method_point_a: :origin_port_id,
        object_method_point_z: :destination_port_id,
        object_method_start_date: :departure_date,
        object_method_end_date: :arrival_date
      }
    end

    subject do
      described_class.call(
        objects: Sailing.all,
        point_a: origin_port.id,
        point_z: destination_port.id,
        start_date: start_date,
        mapping: mapping
      )
    end

    context 'with invalid inputs' do
      it 'raises an error when inputs are invalid' do
        expect {
          described_class.call(
            objects: nil,
            point_a: origin_port.id,
            point_z: destination_port.id,
            start_date: start_date,
            mapping: mapping
          )
        }.to raise_error(RoutePlanner::InvalidInputError)
      end
    end

    context 'with direct path' do
      before do
        sailing1
      end

      it 'returns the correct path ids' do
        expect(subject).to eq([sailing1.id])
      end
    end

    context 'with multiple path options' do
      let(:intermediate_port) { create(:port, code: 'FRMAR') }

      let(:sailing1) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: intermediate_port,
          departure_date: Date.new(2025, 6, 5),
          arrival_date: Date.new(2025, 6, 9),
          days: 3,
          cost_in_eur: 300.00,
          sailing_rate: sailing_rate
        )
      end

      let(:sailing2) do
        create(:sailing,
          origin_port: intermediate_port,
          destination_port: destination_port,
          departure_date: Date.new(2025, 6, 9),
          arrival_date: Date.new(2025, 6, 12),
          days: 3,
          cost_in_eur: 300.00,
          sailing_rate: sailing_rate
        )
      end

      let(:sailing3) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          departure_date: Date.new(2025, 6, 5),
          arrival_date: Date.new(2025, 6, 15),
          days: 10,
          cost_in_eur: 700.00, # Increased cost to ensure this is not chosen
          sailing_rate: sailing_rate
        )
      end

      before do
        sailing1
        sailing2
        sailing3
      end

      it 'returns the cheapest path ids' do
        expect(subject).to match_array([sailing1.id, sailing2.id])
      end
    end

    context 'with path that starts before start_date' do
      before do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          departure_date: Date.new(2025, 5, 25),
          arrival_date: Date.new(2025, 5, 30),
          days: 5,
          cost_in_eur: 100.00,
          sailing_rate: sailing_rate
        )
        sailing1
      end

      it 'ignores paths starting before start_date' do
        expect(subject).to eq([sailing1.id])
      end
    end

    context 'when no valid path exists' do
      # Create a different port that won't have any paths
      let(:unreachable_port) { create(:port, code: 'UNREACHABLE') }
      let(:third_port) { create(:port, code: 'THIRD') }

      before do
        # Create some sailings to ensure we have a valid collection
        create(:sailing,
          origin_port: origin_port,
          destination_port: third_port,
          departure_date: Date.new(2025, 6, 5),
          arrival_date: Date.new(2025, 6, 10),
          days: 5,
          cost_in_eur: 500.00,
          sailing_rate: sailing_rate
        )
        unreachable_port # Ensure this port exists
      end

      it 'returns an empty array' do
        # Use unreachable_port as destination - no sailing goes there
        result = described_class.call(
          objects: Sailing.all,
          point_a: origin_port.id,
          point_z: unreachable_port.id,
          start_date: start_date,
          mapping: mapping
        )
        expect(result).to eq([])
      end
    end

    context 'with overlapping dates' do
      let(:intermediate_port) { create(:port, code: 'BRSSZ') }

      let(:sailing1) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: intermediate_port,
          departure_date: Date.new(2025, 6, 5),
          arrival_date: Date.new(2025, 6, 10),
          days: 5,
          cost_in_eur: 300.00,
          sailing_rate: sailing_rate
        )
      end

      let(:sailing2) do
        create(:sailing,
          origin_port: intermediate_port,
          destination_port: destination_port,
          departure_date: Date.new(2025, 6, 8), # Overlaps with arrival of sailing1
          arrival_date: Date.new(2025, 6, 15),
          days: 7,
          cost_in_eur: 200.00,
          sailing_rate: sailing_rate
        )
      end

      before do
        sailing1
        sailing2
      end

      it 'does not include overlapping paths' do
        expect(subject).to eq([])
      end
    end

    context 'with custom test objects' do
      let(:location_a) { 'LocationA' }
      let(:location_b) { 'LocationB' }
      let(:location_c) { 'LocationC' }
      let(:start_time) { Time.new(2025, 6, 1, 10, 0, 0) }

      let(:test_objects) do
        [
          # Direct path from A to C (expensive)
          TestObject.new(
            id: 1,
            source: location_a,
            destination: location_c,
            start_time: Time.new(2025, 6, 1, 12, 0, 0),
            end_time: Time.new(2025, 6, 1, 14, 0, 0),
            price: 100
          ),

          # Path A to B (cheap)
          TestObject.new(
            id: 2,
            source: location_a,
            destination: location_b,
            start_time: Time.new(2025, 6, 1, 12, 0, 0),
            end_time: Time.new(2025, 6, 1, 13, 0, 0),
            price: 30
          ),

          # Path B to C (cheap)
          TestObject.new(
            id: 3,
            source: location_b,
            destination: location_c,
            start_time: Time.new(2025, 6, 1, 13, 30, 0), # After first leg arrival
            end_time: Time.new(2025, 6, 1, 14, 30, 0),
            price: 30
          ),

          # Path starting before start_time (should be ignored)
          TestObject.new(
            id: 4,
            source: location_a,
            destination: location_c,
            start_time: Time.new(2025, 5, 31, 12, 0, 0), # Before start_time
            end_time: Time.new(2025, 5, 31, 14, 0, 0),
            price: 20
          )
        ]
      end

      let(:test_mapping) do
        {
          object_method_cost: :price,
          object_method_point_a: :source,
          object_method_point_z: :destination,
          object_method_start_date: :start_time,
          object_method_end_date: :end_time
        }
      end

      it 'finds the cheapest path with custom objects' do
        result = described_class.call(
          objects: test_objects,
          point_a: location_a,
          point_z: location_c,
          start_date: start_time,
          mapping: test_mapping
        )

        # The cheapest path should be objects 2->3 instead of the direct path 1
        expect(result).to eq([2, 3])
      end

      it 'handles different start and end points' do
        result = described_class.call(
          objects: test_objects,
          point_a: location_a,
          point_z: location_b,
          start_date: start_time,
          mapping: test_mapping
        )

        expect(result).to eq([2])
      end

      it 'respects the start date' do
        # Use an earlier start time which should allow object with id 4
        earlier_start = Time.new(2025, 5, 30, 10, 0, 0)

        result = described_class.call(
          objects: test_objects,
          point_a: location_a,
          point_z: location_c,
          start_date: earlier_start,
          mapping: test_mapping
        )

        # Should pick object 4 as it's now valid and cheaper
        expect(result).to include(4)
      end
    end
  end
end