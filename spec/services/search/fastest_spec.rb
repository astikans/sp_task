require 'rails_helper'

RSpec.describe Search::Fastest, type: :service do
  describe '.search' do
    let(:origin_port) { create(:port, code: 'NLRTM') }
    let(:destination_port) { create(:port, code: 'ESBCN') }
    let(:intermediate_port) { create(:port, code: 'FRMAR') }

    subject { described_class.search(origin_port, destination_port) }

    context 'when there are direct sailings between the ports' do
      let!(:fastest_sailing) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          days: 5,
          cost_in_eur: 300.00,
          departure_date: Date.today,
          arrival_date: Date.today + 5.days
        )
      end

      let!(:slower_sailing) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          days: 8,
          cost_in_eur: 200.00,
          departure_date: Date.today + 1.day,
          arrival_date: Date.today + 9.days
        )
      end

      it 'returns the fastest direct sailing between the ports' do
        expect(subject).to be_an(Array)
        expect(subject.length).to eq(1)

        sailing_result = subject.first
        expect(sailing_result['origin_port']).to eq(origin_port.code)
        expect(sailing_result['destination_port']).to eq(destination_port.code)
        expect(sailing_result['departure_date']).to eq(fastest_sailing.departure_date.to_s)
        expect(sailing_result['arrival_date']).to eq(fastest_sailing.arrival_date.to_s)
      end

      it 'formats the result using Formatters::Sailings' do
        expect(Formatters::Sailings).to receive(:format).with(kind_of(ActiveRecord::Relation)).and_call_original
        subject
      end
    end

    context 'when there are no sailings between the ports' do
      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'with multiple route options of different durations' do
      let!(:direct_sailing) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          days: 7,
          cost_in_eur: 300.00,
          departure_date: Date.today,
          arrival_date: Date.today + 7.days
        )
      end

      let!(:indirect_sailing1) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: intermediate_port,
          days: 2,
          cost_in_eur: 150.00,
          departure_date: Date.today,
          arrival_date: Date.today + 2.days
        )
      end

      let!(:indirect_sailing2) do
        create(:sailing,
          origin_port: intermediate_port,
          destination_port: destination_port,
          days: 3,
          cost_in_eur: 200.00,
          departure_date: Date.today + 2.days,
          arrival_date: Date.today + 5.days
        )
      end

      it 'returns the fastest path even if indirect' do
        expect(subject.length).to eq(2)

        departure_dates = subject.map { |sailing| sailing['departure_date'] }
        expect(departure_dates).to eq([indirect_sailing1.departure_date.to_s, indirect_sailing2.departure_date.to_s])

        arrival_dates = subject.map { |sailing| sailing['arrival_date'] }
        expect(arrival_dates).to eq([indirect_sailing1.arrival_date.to_s, indirect_sailing2.arrival_date.to_s])
      end
    end

    context 'when multiple routes have the same duration' do
      let!(:sailing_early) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          days: 5,
          cost_in_eur: 300.00,
          departure_date: Date.today,
          arrival_date: Date.today + 5.days
        )
      end

      let!(:sailing_late) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          days: 5,
          cost_in_eur: 200.00,
          departure_date: Date.today + 1.day,
          arrival_date: Date.today + 6.days
        )
      end

      it 'returns the route that departs earlier' do
        expect(subject.length).to eq(1)

        sailing_result = subject.first
        expect(sailing_result['departure_date']).to eq(sailing_early.departure_date.to_s)
        expect(sailing_result['arrival_date']).to eq(sailing_early.arrival_date.to_s)
      end
    end

    context 'when testing the cost_method' do
      it 'uses days as the cost method' do
        instance = described_class.new(origin_port, destination_port)
        expect(instance.send(:cost_method)).to eq(:days)
      end
    end
  end
end