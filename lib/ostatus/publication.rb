module OStatus
  class Publication
    # @param [String] url Topic URL
    # @param [Array] hubs URLs of the hubs which should be notified about the update
    def initialize(url, hubs = [])
      @url  = url
      @hubs = hubs.map { |hub_url| Addressable::URI.parse(hub_url) }
    end

    # Notifies hubs about the update to the topic URL
    def publish
      @hubs.each { |hub| http_client.post(hub, form: { 'hub.mode' => 'publish', 'hub.url' => @url }) }
    end

    private

    def http_client
      HTTP
    end
  end
end
