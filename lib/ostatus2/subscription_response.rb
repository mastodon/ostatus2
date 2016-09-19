module OStatus2
  class SubscriptionResponse
    # @param [Integer] code HTTP status code
    # @param [String] body HTTP response body
    def initialize(code, body)
      @code = code
      @body = body
    end

    # Was the hub operation successful?
    # @return [Boolean]
    def successful?
      @code == 202
    end

    # Was the hub operation not successful?
    # @return [Boolean]
    def failed?
      !successful?
    end

    # Returns error message if the operation was not successful
    # @return [String]
    def message
      @body
    end
  end
end
