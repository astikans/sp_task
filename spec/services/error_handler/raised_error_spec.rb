require 'rails_helper'

RSpec.describe ErrorHandler::RaisedError do
  describe '#initialize' do
    it 'stores the data and formats the message' do
      data = { key: 'value', nested: { data: 123 } }
      error = ErrorHandler::RaisedError.new('Test error message', data)

      expect(error.data).to eq(data)
      expect(error.message).to include('Test error message')
      expect(error.message).to include(data.inspect)
    end

    it 'works with an empty data hash' do
      error = ErrorHandler::RaisedError.new('Just a message')

      expect(error.data).to eq({})
      expect(error.message).to include('Just a message')
      expect(error.message).to include('{}')
    end
  end

  describe '.handle_active_record_error' do
    context 'with ActiveRecord::RecordInvalid' do
      it 'formats the error with record details' do
        # We need to understand what's happening in the method
        # Let's directly test the ActiveRecord::RecordInvalid branch

        # Create an actual invalid record using a stub model
        record = double(
          class: double(name: 'TestModel'),
          attributes: { 'id' => 1, 'name' => 'Test' },
          errors: double(
            full_messages: ['Name is invalid', 'Email is required'],
            details: { name: [{ error: 'invalid' }], email: [{ error: 'blank' }] }
          )
        )

        # We need to use a real ArActiveRecord::RecordInvalid, but stub its internals
        error_class = Class.new(StandardError) do
          attr_reader :record
          def initialize(record)
            @record = record
            super("Record invalid")
          end
        end

        # Allow the class to act like ActiveRecord::RecordInvalid
        allow(ActiveRecord::RecordInvalid).to receive(:===) do |other|
          other.is_a?(error_class)
        end

        # Create our error instance
        error = error_class.new(record)

        # Mock logger to prevent actual logging
        allow(Rails.logger).to receive(:error)

        # Test the method
        result = nil
        expect {
          result = ErrorHandler::RaisedError.handle_active_record_error(error)
        }.to raise_error(ErrorHandler::RaisedError) do |raised_error|
          expect(raised_error.message).to include('Invalid record')
          expect(raised_error.data[:record_class]).to eq('TestModel')
          expect(raised_error.data[:attributes]).to eq({ 'id' => 1, 'name' => 'Test' })
          expect(raised_error.data[:errors]).to eq(['Name is invalid', 'Email is required'])
          expect(raised_error.data[:error_details]).to eq({
            name: [{ error: 'invalid' }],
            email: [{ error: 'blank' }]
          })
        end
      end
    end

    context 'with other StandardError' do
      it 'formats the error with error details' do
        original_error = StandardError.new('Something went wrong')
        allow(original_error).to receive(:backtrace).and_return([
          'line1',
          'line2',
          'line3',
          'line4',
          'line5',
          'line6'
        ])

        expect(Rails.logger).to receive(:error).twice

        expect {
          ErrorHandler::RaisedError.handle_active_record_error(original_error)
        }.to raise_error(ErrorHandler::RaisedError) do |error|
          expect(error.message).to include('Data failed: Something went wrong')
          expect(error.data[:error_class]).to eq('StandardError')
          expect(error.data[:message]).to eq('Something went wrong')
          expect(error.data[:backtrace]).to eq(['line1', 'line2', 'line3', 'line4', 'line5'])
        end
      end
    end
  end
end