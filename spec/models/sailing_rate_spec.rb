require 'rails_helper'

RSpec.describe SailingRate, type: :model do
  describe 'validations' do
    subject { SailingRate.new(code: 'ETRG', rate: 100, rate_currency: 'EUR') }

    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:rate) }
    it { should validate_presence_of(:rate_currency) }
    it { should validate_uniqueness_of(:code) }
  end

  describe 'associations' do
    it { should have_many(:sailings).dependent(:destroy) }
  end

  describe '#eur?' do
    subject { sailing_rate.eur? }
    context 'when rate_currency is EUR' do
      let(:sailing_rate) { build(:sailing_rate, rate_currency: 'EUR') }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when rate_currency is not EUR' do
      let(:sailing_rate) { build(:sailing_rate, rate_currency: 'USD') }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end