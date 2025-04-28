# This class validates user input for port codes
# It inherits from InputValidators::Base and implements the required methods
# The port code must exist in the Port model's database records
module InputValidators
  class Port < Base
    def error_message
      %{Invalid port. Next time, please enter a valid port from the
        following list: #{::Port.pluck(:code).join(", ")}
      }.squish
    end

    private

    def valid?
      ::Port.exists?(code: @input)
    end
  end
end