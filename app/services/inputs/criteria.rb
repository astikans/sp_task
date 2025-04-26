module Inputs
  class Criteria < Base
    AVAILABLE_CRITERIA = ["cheapest-direct", "cheapest", "fastest"]

    private

    def prompt_message
      "Enter the criteria (#{AVAILABLE_CRITERIA.join(", ")}): "
    end

    def validator_class
      InputValidators::Criteria
    end

    def return_valid_value
      @input
    end
  end
end
