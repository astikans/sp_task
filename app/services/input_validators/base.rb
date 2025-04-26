module InputValidators
  class Base
    def initialize(input)
      @input = input
    end

    def validate
      valid?
    end

    def error_message
      raise NotImplementedError, "Subclasses must implement the error_message method"
    end

    private

    def valid?
      raise NotImplementedError, "Subclasses must implement the validate method"
    end
  end
end