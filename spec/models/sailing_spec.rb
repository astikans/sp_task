require 'rails_helper'

RSpec.describe Sailing, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:departure_date) }
    it { should validate_presence_of(:arrival_date) }
    it { should validate_presence_of(:days) }
    it { should validate_presence_of(:cost_in_eur) }

    describe 'departure_date_before_arrival_date validation' do
      let(:port) { create(:port) }
      let(:sailing_rate) { create(:sailing_rate) }

      context 'when departure_date is before arrival_date' do
        subject { build(:sailing, departure_date: Date.today, arrival_date: Date.today + 5.days) }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'when departure_date is equal to arrival_date' do
        subject { build(:sailing, departure_date: Date.today, arrival_date: Date.today) }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:departure_date]).to include('must be before arrival date')
        end
      end

      context 'when departure_date is after arrival_date' do
        subject { build(:sailing, departure_date: Date.today + 5.days, arrival_date: Date.today) }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:departure_date]).to include('must be before arrival date')
        end
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:origin_port).class_name('Port') }
    it { should belong_to(:destination_port).class_name('Port') }
    it { should belong_to(:sailing_rate) }
  end
end