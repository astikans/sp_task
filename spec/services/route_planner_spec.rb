require 'rails_helper'

RSpec.describe RoutePlanner do
  describe '.call' do
    let(:origin_port) { create(:port, code: 'NLRTM') }
    let(:destination_port) { create(:port, code: 'ESBCN') }
    let(:intermediate_port) { create(:port, code: 'FRMAR') }
    let(:other_port) { create(:port, code: 'DEHAM') }
    let(:start_date) { Date.today }
    let(:cost_method) { :cost_in_eur }

    subject do
      described_class.call(
        sailings: Sailing.all,
        cost_method: cost_method,
        origin_port: origin_port,
        destination_port: destination_port,
        start_date: start_date
      )
    end

    context 'with valid inputs' do
      context 'when there are direct sailings between the ports' do
        let!(:cheapest_sailing) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: destination_port,
            days: 8,
            cost_in_eur: 200.00,
            departure_date: start_date + 1.day,
            arrival_date: start_date + 9.days
          )
        end

        let!(:expensive_sailing) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: destination_port,
            days: 5,
            cost_in_eur: 300.00,
            departure_date: start_date,
            arrival_date: start_date + 5.days
          )
        end

        it 'returns the id of the cheapest direct sailing' do
          expect(subject).to eq([cheapest_sailing.id])
        end
      end

      context 'when there are no sailings between the requested ports' do
        let!(:unrelated_sailing) do
          create(:sailing,
            origin_port: other_port,
            destination_port: intermediate_port,
            days: 5,
            cost_in_eur: 250.00,
            departure_date: start_date,
            arrival_date: start_date + 5.days
          )
        end

        it 'returns an empty array' do
          expect(subject).to eq([])
        end
      end

      context 'with multiple route options of different costs' do
        let!(:direct_sailing) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: destination_port,
            days: 7,
            cost_in_eur: 300.00,
            departure_date: start_date,
            arrival_date: start_date + 7.days
          )
        end

        let!(:indirect_sailing1) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: intermediate_port,
            days: 3,
            cost_in_eur: 100.00,
            departure_date: start_date,
            arrival_date: start_date + 3.days
          )
        end

        let!(:indirect_sailing2) do
          create(:sailing,
            origin_port: intermediate_port,
            destination_port: destination_port,
            days: 5,
            cost_in_eur: 150.00,
            departure_date: start_date + 3.days,
            arrival_date: start_date + 8.days
          )
        end

        it 'returns the ids of the sailings in the cheapest path' do
          expect(subject).to match_array([indirect_sailing1.id, indirect_sailing2.id])
        end
      end

      context 'when sailings cannot connect due to departure/arrival date constraints' do
        let!(:sailing1) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: intermediate_port,
            days: 3,
            cost_in_eur: 100.00,
            departure_date: start_date,
            arrival_date: start_date + 3.days
          )
        end

        let!(:sailing2) do
          create(:sailing,
            origin_port: intermediate_port,
            destination_port: destination_port,
            days: 5,
            cost_in_eur: 150.00,
            departure_date: start_date + 2.days, # This departs before sailing1 arrives
            arrival_date: start_date + 7.days
          )
        end

        it 'does not include invalid paths' do
          expect(subject).to eq([])
        end
      end

      context 'with sailings before the start date' do
        let!(:sailing_before_start) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: destination_port,
            days: 5,
            cost_in_eur: 100.00,
            departure_date: start_date - 1.day,
            arrival_date: start_date + 4.days
          )
        end

        let!(:valid_sailing) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: destination_port,
            days: 7,
            cost_in_eur: 200.00,
            departure_date: start_date + 1.day,
            arrival_date: start_date + 8.days
          )
        end

        it 'only considers sailings after the start date' do
          expect(subject).to eq([valid_sailing.id])
        end
      end

      context 'with a different cost method' do
        let(:cost_method) { :days }

        let!(:long_sailing) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: destination_port,
            days: 10,
            cost_in_eur: 150.00,
            departure_date: start_date,
            arrival_date: start_date + 10.days
          )
        end

        let!(:short_sailing) do
          create(:sailing,
            origin_port: origin_port,
            destination_port: destination_port,
            days: 7,
            cost_in_eur: 300.00,
            departure_date: start_date + 1.day,
            arrival_date: start_date + 8.days
          )
        end

        it 'uses the specified cost method for comparison' do
          expect(subject).to eq([short_sailing.id])
        end
      end
    end

    context 'with invalid inputs' do
      context 'when sailings is nil' do
        subject do
          described_class.call(
            sailings: nil,
            cost_method: cost_method,
            origin_port: origin_port,
            destination_port: destination_port,
            start_date: start_date
          )
        end

        it 'raises an InvalidInputError' do
          expect { subject }.to raise_error(RoutePlanner::InvalidInputError, "Invalid inputs")
        end
      end

      context 'when cost_method is nil' do
        subject do
          described_class.call(
            sailings: Sailing.all,
            cost_method: nil,
            origin_port: origin_port,
            destination_port: destination_port,
            start_date: start_date
          )
        end

        it 'raises an InvalidInputError' do
          expect { subject }.to raise_error(RoutePlanner::InvalidInputError, "Invalid inputs")
        end
      end

      context 'when origin_port is nil' do
        subject do
          described_class.call(
            sailings: Sailing.all,
            cost_method: cost_method,
            origin_port: nil,
            destination_port: destination_port,
            start_date: start_date
          )
        end

        it 'raises an InvalidInputError' do
          expect { subject }.to raise_error(RoutePlanner::InvalidInputError, "Invalid inputs")
        end
      end

      context 'when destination_port is nil' do
        subject do
          described_class.call(
            sailings: Sailing.all,
            cost_method: cost_method,
            origin_port: origin_port,
            destination_port: nil,
            start_date: start_date
          )
        end

        it 'raises an InvalidInputError' do
          expect { subject }.to raise_error(RoutePlanner::InvalidInputError, "Invalid inputs")
        end
      end

      context 'when start_date is nil' do
        subject do
          described_class.call(
            sailings: Sailing.all,
            cost_method: cost_method,
            origin_port: origin_port,
            destination_port: destination_port,
            start_date: nil
          )
        end

        it 'raises an InvalidInputError' do
          expect { subject }.to raise_error(RoutePlanner::InvalidInputError, "Invalid inputs")
        end
      end
    end
  end
end