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