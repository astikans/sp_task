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