module ErrorHandler
  module Wrapper
    def with_error_handling
      yield
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      RaisedError.handle_active_record_error(e)
    rescue StandardError => e
      # If it's already our custom RaisedError, just re-raise it
      raise e if e.is_a?(RaisedError)

      # Otherwise use our handler
      RaisedError.handle_active_record_error(e)
    end

    def lookup_with_error_handling(class_name, **params)
      begin
        yield
      rescue ActiveRecord::RecordNotFound => e
        lookup_data = { model: class_name.to_s, params: params }
        message = "Failed to find #{lookup_data}"

        raise RaisedError.new(message, lookup_data)
      end
    end
  end
end