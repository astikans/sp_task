require 'rails_helper'

RSpec.describe InputValidators::Criteria do
  describe '#validate' do
    context 'when input is valid' do
      it 'returns true for cheapest-direct' do
        validator = described_class.new('cheapest-direct')
        expect(validator.validate).to be true
      end

      it 'returns true for cheapest' do
        validator = described_class.new('cheapest')
        expect(validator.validate).to be true
      end

      it 'returns true for fastest' do
        validator = described_class.new('fastest')
        expect(validator.validate).to be true
      end
    end

    context 'when input is invalid' do
      it 'returns false for an unknown criteria' do
        validator = described_class.new('unknown')
        expect(validator.validate).to be false
      end

      it 'returns false for nil input' do
        validator = described_class.new(nil)
        expect(validator.validate).to be false
      end

      it 'returns false for empty string' do
        validator = described_class.new('')
        expect(validator.validate).to be false
      end
    end
  end

  describe '#valid?' do
    it 'returns true if input is in AVAILABLE_CRITERIA' do
      validator = described_class.new('cheapest')
      expect(validator.send(:valid?)).to be true
    end

    it 'returns false if input is not in AVAILABLE_CRITERIA' do
      validator = described_class.new('something-else')
      expect(validator.send(:valid?)).to be false
    end
  end

  describe '#error_message' do
    it 'returns a message with the list of available criteria' do
      validator = described_class.new('invalid')

      allow(CriteriaConstants::AVAILABLE_CRITERIA).to receive(:keys).and_return(['cheapest', 'fastest', 'cheapest-direct'])
      allow(CriteriaConstants::AVAILABLE_CRITERIA.keys).to receive(:join).with(", ").and_return('cheapest, fastest, cheapest-direct')

      expected_message = "Invalid criteria. Next time, please enter a valid criteria from the following list: cheapest, fastest, cheapest-direct"
      expect(validator.error_message).to eq(expected_message)
    end
  end
end