module OStatus
  class Salmon
    XMLNS = 'http://salmon-protocol.org/ns/magic-env'

    # Create a magical envelope XML document around the original body
    # and sign it with a private key
    # @param [String] body
    # @param [OpenSSL::PKey::RSA] key
    # @return [String] Magical envelope XML
    def pack(body, key)
      signed    = plaintext_signature(body)
      signature = Base64.urlsafe_encode64(key.sign(digest, signed))

      Nokogiri::XML::Builder.new do |xml|
        xml['me'].env({ 'xmlns:me' => XMLNS }) do
          xml['me'].data({ type: 'application/atom+xml' }, Base64.urlsafe_encode64(body))
          xml['me'].encoding('base64url')
          xml['me'].alg('RSA-SHA256')
          xml['me'].sig({ keyhash: Base64.urlsafe_encode64(key.public_key.to_s) }, signature)
        end
      end.to_xml
    end

    # Deliver the magical envelope to a Salmon endpoint
    # @param [String] salmon_url Salmon endpoint URL
    # @param [String] envelope Magical envelope
    # @raise [HTTP::Error] Error raised upon delivery failure
    # @raise [OpenSSL::SSL::SSLError] Error raised upon SSL-related failure during delivery
    # @return [HTTP::Response]
    def post(salmon_url, envelope)
      http_client.headers(HTTP::Headers::CONTENT_TYPE => 'application/magic-envelope+xml').post(Addressable::URI.parse(salmon_url), body: envelope)
    end

    # Unpack a magical envelope to get the content inside
    # @param [String] raw_body Magical envelope
    # @param [OpenSSL::PKey::RSA] key
    # @raise [OStatus::BadSalmonError] Error raised when the integrity of the envelope could not be verified with the given key
    # @return [String] Content inside the envelope
    def unpack(raw_body, key)
      xml = Nokogiri::XML(raw_body)

      data      = xml.at_xpath('//me:data')
      type      = data.attribute('type').value
      body      = Base64::urlsafe_decode64(data.content)
      sig       = xml.at_xpath('//me:sig')
      keyhash   = Base64::urlsafe_decode64(sig.attribute('keyhash').value)
      signature = Base64::urlsafe_decode64(sig.content)
      encoding  = xml.at_xpath('//me:encoding').content
      alg       = xml.at_xpath('//me:alg').content

      unless key.public_key.verify(digest, signature, plaintext_signature(body))
        raise OStatus::BadSalmonError
      end

      body
    end

    private

    def http_client
      HTTP
    end

    def digest
      OpenSSL::Digest::SHA256.new
    end

    def plaintext_signature(data)
      [data, 'application/atom+xml', 'base64url', 'RSA-SHA256'].map { |i| Base64.urlsafe_encode64(i) }.join('.')
    end
  end
end
