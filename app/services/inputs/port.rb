# This class handles user input for port codes
# It inherits from Inputs::Base and implements the required methods
# The port_type parameter determines whether this is an origin or destination port
# The port code must exist in the Port model's database records
module Inputs
  class Port < Base
    private

    def port_type
      @additional_params[:port_type]
    end

    def prompt_message
      "Enter the #{port_type}: "
    end

    def validator_class
      InputValidators::Port
    end

    def return_valid_value
      ::Port.find_by(code: @input)
    end
  end
end