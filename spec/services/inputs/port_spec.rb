require 'rails_helper'

RSpec.describe Inputs::Port do
  describe '.input' do
    let(:port_type) { 'origin port' }
    let(:valid_port) { 'NLRTM' }
    let(:invalid_port) { 'INVALID' }
    let(:validator_instance) { instance_double(InputValidators::Port) }
    let(:port_instance) { instance_double(Port) }

    before do
      # Stub user input
      allow_any_instance_of(described_class).to receive(:gets).and_return("#{valid_port}\n")
      # Stub print and puts to avoid output during tests
      allow_any_instance_of(Kernel).to receive(:print)
      allow_any_instance_of(Kernel).to receive(:puts)
    end

    context 'when the user enters a valid port code' do
      before do
        allow(InputValidators::Port).to receive(:new).with(valid_port).and_return(validator_instance)
        allow(validator_instance).to receive(:validate).and_return(true)
        allow(Port).to receive(:find_by).with(code: valid_port).and_return(port_instance)
      end

      it 'returns the port object' do
        expect(described_class.input(port_type: port_type)).to eq(port_instance)
      end

      it 'does not exit the program' do
        expect { described_class.input(port_type: port_type) }.not_to raise_error
      end
    end

    context 'when the user enters an invalid port code' do
      before do
        allow_any_instance_of(described_class).to receive(:gets).and_return("#{invalid_port}\n")
        allow(InputValidators::Port).to receive(:new).with(invalid_port).and_return(validator_instance)
        allow(validator_instance).to receive(:validate).and_return(false)
        allow(validator_instance).to receive(:error_message).and_return("Error: Invalid port.")
        # Stub exit to prevent test from actually exiting
        allow_any_instance_of(Kernel).to receive(:exit)
      end

      it 'displays an error message and exits' do
        expect_any_instance_of(Kernel).to receive(:puts).with("Error: Invalid port.")
        expect_any_instance_of(Kernel).to receive(:puts).with("Exiting.")

        described_class.input(port_type: port_type)
      end
    end
  end
end