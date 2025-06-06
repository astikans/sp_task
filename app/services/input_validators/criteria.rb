# This class validates user input for search criteria
# It inherits from InputValidators::Base and implements the required methods
# The criteria must be one of the predefined values in Inputs::Criteria::AVAILABLE_CRITERIA
module InputValidators
  class Criteria < Base
    def error_message
      %{Invalid criteria. Next time, please enter a valid criteria from the
        following list: #{available_criteria_input_values.join(", ")}
      }.squish
    end

    private

    def valid?
      available_criteria_input_values.include?(@input)
    end

    def available_criteria_input_values
      CriteriaConstants::AVAILABLE_CRITERIA.keys
    end
  end
end