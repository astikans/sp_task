module Inputs
  class Base
    def self.input(...)
      new(...).input
    end

    def initialize(additional_params = {})
      @additional_params = additional_params
    end

    def input
      input_value
      validate_or_exit
      return_valid_value
    end

    private

    def input_value
      print prompt_message
      @input = gets.chomp
    end

    def validate_or_exit
      validator = validator_class.new(@input)
      unless validator.validate
        puts validator.error_message
        puts "Exiting."
        exit
      end
    end

    def prompt_message
      raise NotImplementedError, "Subclasses must implement the prompt_message method"
    end

    def validator_class
      raise NotImplementedError, "Subclasses must implement the validator_class method"
    end

    def return_valid_value
      raise NotImplementedError, "Subclasses must implement the return_value method"
    end
  end
end