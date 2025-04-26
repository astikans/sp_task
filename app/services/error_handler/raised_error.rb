module ErrorHandler
  class RaisedError < StandardError
    attr_reader :data

    def initialize(message, data = {})
      @data = data
      super("#{message}\nData: #{data.inspect}")
    end

    def self.handle_active_record_error(error)
      case error
      when ActiveRecord::RecordInvalid
        record = error.record
        data = {
          record_class: record.class.name,
          attributes: record.attributes,
          errors: record.errors.full_messages,
          error_details: record.errors.details
        }
        message = "Invalid record: #{error.message}"
      else
        data = {
          error_class: error.class.name,
          message: error.message,
          backtrace: error.backtrace&.first(5)
        }

        message = "Data failed: #{error.message}"
      end

      Rails.logger.error(message)
      Rails.logger.error(data)
      raise new(message, data)
    end
  end
end