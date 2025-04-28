# This class handles user input for search criteria
# It inherits from Inputs::Base and implements the required methods
# Available criteria are:
# - cheapest-direct: finds the cheapest direct route between ports
# - cheapest: finds the cheapest route overall, including connections
# - fastest: finds the fastest route between ports
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
