require 'rails_helper'

RSpec.describe Search::CheapestDirect, type: :service do
  describe '.search' do
    let(:origin_port) { create(:port, code: 'NLRTM') }
    let(:destination_port) { create(:port, code: 'ESBCN') }

    subject { described_class.search(origin_port, destination_port) }

    context 'when there are sailings between the ports' do
      let!(:cheapest_sailing) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          cost_in_eur: 200.00,
          sailing_rate: create(:sailing_rate, code: 'CHEAP', rate: 200.00, rate_currency: 'EUR'),
          departure_date: Date.today,
          arrival_date: Date.today + 3.days
        )
      end

      let!(:expensive_sailing) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          cost_in_eur: 350.00,
          sailing_rate: create(:sailing_rate, code: 'EXPENSIVE', rate: 350.00, rate_currency: 'EUR'),
          departure_date: Date.today + 1.day,
          arrival_date: Date.today + 4.days
        )
      end

      it 'returns the cheapest direct sailing between the ports' do
        expect(subject).to be_an(Array)
        expect(subject.length).to eq(1)

        sailing_result = subject.first
        expect(sailing_result['origin_port']).to eq(origin_port.code)
        expect(sailing_result['destination_port']).to eq(destination_port.code)
        expect(sailing_result['sailing_code']).to eq('CHEAP')
        expect(sailing_result['rate']).to eq('200.0')
      end

      it 'formats the result using Formatters::Sailings' do
        expect(Formatters::Sailings).to receive(:format).with(kind_of(ActiveRecord::Relation)).and_call_original
        subject
      end
    end

    context 'when there are no direct sailings between the ports' do
      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'with multiple direct sailings with the same cost' do
      let!(:earlier_sailing) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          cost_in_eur: 200.00,
          sailing_rate: create(:sailing_rate, code: 'EARLIER', rate: 200.00, rate_currency: 'EUR'),
          departure_date: Date.today,
          arrival_date: Date.today + 3.days
        )
      end

      let!(:later_sailing) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          cost_in_eur: 200.00,
          sailing_rate: create(:sailing_rate, code: 'LATER', rate: 200.00, rate_currency: 'EUR'),
          departure_date: Date.today + 1.day,
          arrival_date: Date.today + 4.days
        )
      end

      it 'returns the earlier sailing when costs are equal' do
        expect(subject).to be_an(Array)
        expect(subject.length).to eq(1)
        expect(subject.first['sailing_code']).to eq('EARLIER')
      end
    end
  end
end