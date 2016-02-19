module OStatus
  class Subscription
    # @param [String] topic_url The URL of the topic of the subscription
    # @param [Hash] options
    # @option options [String] :callback Callback URL
    # @option options [String] :secret Secret key of the subscription
    # @option options [String] :token Verification token of the subscription
    def initialize(topic_url, options = {})
      @topic_url    = topic_url
      @callback_url = options[:callback] || ''
      @secret       = options[:secret]   || ''
      @token        = options[:token]    || ''
    end

    # Subscribe to the topic via a specified hub
    # @param [String] hub URL of the hub
    # @return [Boolean]
    def subscribe(hub)
      update_subscription(:subscribe, hub)
    end

    # Unsubscribe from the topic via a specified hub
    # @param [String] hub URL of the hub
    # @return [Boolean]
    def unsubscribe(hub)
      update_subscription(:unsubscribe, hub)
    end

    # Check if the hub is responding to the right subscription request
    # @param [String] topic_url A hub.topic from the hub
    # @param [String] token A hub.verify_token from the hub
    # @return [Boolean]
    def valid?(topic_url, token)
      @topic_url == topic_url && @token == token
    end

    # Verify that the feed contents were meant for this subscription
    # @param [String] content
    # @param [String] signature
    # @return [Boolean]
    def verify(content, signature)
      hmac = OpenSSL::HMAC.hexdigest('sha1', @secret, content)
      signature == "sha1=#{hmac}"
    end

    private

    def update_subscription(mode, hub)
      hub_url  = Addressable::URI.parse(hub)
      response = http_client.post(hub_url, form: { 'hub.mode' => mode.to_s, 'hub.callback' => @callback_url, 'hub.verify' => 'async', 'hub.verify_token' => @token, 'hub.lease_seconds' => '', 'hub.secret' => @secret, 'hub.topic' => @topic_url })
      response.code == 200
    end

    def http_client
      HTTP
    end
  end
end
