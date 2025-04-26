require 'rails_helper'

RSpec.describe Formatters::Sailings do
  describe '.format' do
    let(:sailings) { Sailing.where(id: sailing.id) }
    subject { described_class.format(sailings) }

    context 'when sailings are present' do
      let(:origin_port) { create(:port, code: 'NLRTM') }
      let(:destination_port) { create(:port, code: 'ESBCN') }
      let(:sailing_rate) { create(:sailing_rate, code: 'ETRG', rate: 250.50, rate_currency: 'USD') }
      let(:departure_date) { Date.new(2025, 6, 15) }
      let(:arrival_date) { Date.new(2025, 6, 20) }

      let(:sailing) do
        create(:sailing,
          origin_port: origin_port,
          destination_port: destination_port,
          departure_date: departure_date,
          arrival_date: arrival_date,
          sailing_rate: sailing_rate
        )
      end

      it 'formats sailings as expected' do
        expect(subject).to eq(
          [
            {
              "origin_port" => "NLRTM",
              "destination_port" => "ESBCN",
              "departure_date" => departure_date.to_s,
              "arrival_date" => arrival_date.to_s,
              "sailing_code" => "ETRG",
              "rate" => "250.5",
              "rate_currency" => "USD"
            }
          ]
        )
      end
    end

    context 'when sailings are not present' do
      let(:sailings) { Sailing.none }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end
  end
end