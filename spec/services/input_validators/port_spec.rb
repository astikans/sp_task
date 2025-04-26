require 'rails_helper'

RSpec.describe InputValidators::Port do
  describe '#validate' do
    let(:validator) { described_class.new(input) }
    subject { validator.validate }

    context 'when input is valid' do
      let(:port_code) { 'CNSHA' }
      let(:input) { port_code }

      before do
        ::Port.create!(code: port_code)
      end

      it 'returns true for an existing port code' do
        expect(subject).to be true
      end
    end

    context 'when input is invalid - non-existent port code' do
      let(:input) { 'NONEXISTENT' }

      it { expect(subject).to be false }
    end

    context 'when input is invalid - nil input' do
      let(:input) { nil }

      it { expect(subject).to be false }
    end

    context 'when input is invalid - empty string' do
      let(:input) { '' }

      it { expect(subject).to be false }
    end
  end

  describe '#valid?' do
    let(:port_code) { 'CNSHA' }
    let(:validator) { described_class.new(port_code) }

    context 'when port exists' do
      before do
        ::Port.create!(code: port_code)
      end

      it 'returns true' do
        expect(validator.send(:valid?)).to be true
      end
    end

    context 'when port does not exist' do
      let(:port_code) { 'INVALID' }

      it 'returns false' do
        expect(validator.send(:valid?)).to be false
      end
    end
  end

  describe '#error_message' do
    let(:validator) { described_class.new('INVALID') }

    it 'returns a message with the list of valid port codes' do
      port_codes = ['CNSHA', 'NLRTM']
      allow(::Port).to receive(:pluck).with(:code).and_return(port_codes)

      expected_message = "Invalid port. Next time, please enter a valid port from the following list: CNSHA, NLRTM"
      expect(validator.error_message).to eq(expected_message)
    end
  end
end