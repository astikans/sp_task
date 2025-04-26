require 'rails_helper'

RSpec.describe Inputs::Criteria do
  describe '.input' do
    let(:valid_criteria) { 'fastest' }
    let(:invalid_criteria) { 'invalid' }
    let(:validator_instance) { instance_double(InputValidators::Criteria) }

    before do
      # Stub user input
      allow_any_instance_of(described_class).to receive(:gets).and_return("#{valid_criteria}\n")
      # Stub print and puts to avoid output during tests
      allow_any_instance_of(Kernel).to receive(:print)
      allow_any_instance_of(Kernel).to receive(:puts)
    end

    context 'when the user enters a valid criteria' do
      before do
        allow(InputValidators::Criteria).to receive(:new).with(valid_criteria).and_return(validator_instance)
        allow(validator_instance).to receive(:validate).and_return(true)
      end

      it 'returns the criteria entered by the user' do
        expect(described_class.input).to eq(valid_criteria)
      end

      it 'does not exit the program' do
        expect { described_class.input }.not_to raise_error
      end
    end

    context 'when the user enters an invalid criteria' do
      before do
        allow_any_instance_of(described_class).to receive(:gets).and_return("#{invalid_criteria}\n")
        allow(InputValidators::Criteria).to receive(:new).with(invalid_criteria).and_return(validator_instance)
        allow(validator_instance).to receive(:validate).and_return(false)
        allow(validator_instance).to receive(:error_message).and_return("Error: Invalid criteria.")
        # Stub exit to prevent test from actually exiting
        allow_any_instance_of(Kernel).to receive(:exit)
      end

      it 'displays an error message and exits' do
        expect_any_instance_of(Kernel).to receive(:puts).with("Error: Invalid criteria.")
        expect_any_instance_of(Kernel).to receive(:puts).with("Exiting.")

        described_class.input
      end
    end
  end
end