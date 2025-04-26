require 'rails_helper'

RSpec.describe DataImporter, type: :service do
  describe '.call' do
    it 'delegates to a new instance' do
      json_data = {}
      instance = instance_double(DataImporter)

      expect(DataImporter).to receive(:new).with(json_data).and_return(instance)
      expect(instance).to receive(:call)

      DataImporter.call(json_data)
    end
  end

  describe '#call' do
    let(:json_data) do
      {
        'exchange_rates' => {
          '2025-01-01' => { 'usd' => 1.1, 'jpy' => 149.93 },
          '2025-01-02' => { 'usd' => 1.2, 'jpy' => 145.06 }
        },
        'rates' => [
          {
            'sailing_code' => 'ETRG',
            'rate' => '100.00',
            'rate_currency' => 'USD'
          }
        ],
        'sailings' => [
          {
            'origin_port' => 'NLRTM',
            'destination_port' => 'ESBCN',
            'departure_date' => '2025-01-01',
            'arrival_date' => '2025-01-10',
            'sailing_code' => 'ETRG'
          }
        ]
      }
    end

    let(:importer) { DataImporter.new(json_data) }

    it 'performs the import within a transaction' do
      expect(ActiveRecord::Base).to receive(:transaction).and_yield

      expect(importer).to receive(:import_exchange_rates)
      expect(importer).to receive(:import_sailing_rates)
      expect(importer).to receive(:import_sailings_and_ports)

      importer.call
    end

    it 'imports all data correctly', :aggregate_failures do
      expect {
        importer.call
      }.to change(ExchangeRate, :count).by(2)
        .and change(SailingRate, :count).by(1)
        .and change(Port, :count).by(2)
        .and change(Sailing, :count).by(1)

      # Verify exchange rates were imported
      expect(ExchangeRate.find_by(date: '2025-01-01').rates).to eq({ 'usd' => 1.1, 'jpy' => 149.93 })
      expect(ExchangeRate.find_by(date: '2025-01-02').rates).to eq({ 'usd' => 1.2, 'jpy' => 145.06 })

      # Verify sailing rate was imported
      sailing_rate = SailingRate.find_by(code: 'ETRG')
      expect(sailing_rate.rate).to eq(100.00)
      expect(sailing_rate.rate_currency).to eq('USD')

      # Verify ports were imported
      expect(Port.find_by(code: 'NLRTM')).to be_present
      expect(Port.find_by(code: 'ESBCN')).to be_present

      # Verify sailing was imported with correct associations and calculated fields
      sailing = Sailing.last
      expect(sailing.origin_port.code).to eq('NLRTM')
      expect(sailing.destination_port.code).to eq('ESBCN')
      expect(sailing.departure_date).to eq(Date.parse('2025-01-01'))
      expect(sailing.arrival_date).to eq(Date.parse('2025-01-10'))
      expect(sailing.days).to eq(9)
      expect(sailing.sailing_rate).to eq(sailing_rate)
      expect(sailing.cost_in_eur).to be_within(0.001).of(90.91)
    end

    context 'with duplicate data' do
      it 'does not create duplicate records' do
        # Pre-create the data that would be imported
        ExchangeRate.create!(date: '2025-01-01', rates: { 'usd' => 1.1, 'jpy' => 149.93 })
        ExchangeRate.create!(date: '2025-01-02', rates: { 'usd' => 1.2, 'jpy' => 145.06 })
        sailing_rate = SailingRate.create!(code: 'ETRG', rate: 100.00, rate_currency: 'USD')
        origin_port = Port.create!(code: 'NLRTM')
        destination_port = Port.create!(code: 'ESBCN')
        Sailing.create!(
          origin_port: origin_port,
          destination_port: destination_port,
          departure_date: '2025-01-01',
          arrival_date: '2025-01-10',
          days: 9,
          cost_in_eur: 90.91,
          sailing_rate: sailing_rate
        )

        # Import should not create any additional records
        expect {
          importer.call
        }.to change(ExchangeRate, :count).by(0)
          .and change(SailingRate, :count).by(0)
          .and change(Port, :count).by(0)
          .and change(Sailing, :count).by(0)
      end
    end

    context 'with validation errors' do
      it 'rolls back the transaction if any records are invalid' do
        allow_any_instance_of(ExchangeRate).to receive(:valid?).and_return(false)
        expect_any_instance_of(ExchangeRate).to receive(:errors).at_least(:once).and_return(
          double(full_messages: ['Date cannot be blank'])
        )

        expect {
          expect { importer.call }.to raise_error(ActiveRecord::RecordInvalid)
        }.not_to change { ExchangeRate.count }
      end
    end

    context 'with missing reference data' do
      it 'raises an error for non-existent references' do
        # Create a sailing with a sailing_code that doesn't exist
        invalid_json_data = json_data.deep_dup
        invalid_json_data['sailings'][0]['sailing_code'] = 'NONEXISTENT'
        invalid_importer = DataImporter.new(invalid_json_data)

        expect {
          invalid_importer.call
        }.to raise_error(NoMethodError)
      end

      it 'raises an error when required exchange rate is missing' do
        # Create a sailing with a departure_date that has no exchange rate
        invalid_json_data = json_data.deep_dup
        invalid_json_data['sailings'][0]['departure_date'] = '2025-01-03'
        invalid_importer = DataImporter.new(invalid_json_data)

        expect {
          invalid_importer.call
        }.to raise_error(NoMethodError)
      end
    end
  end
end