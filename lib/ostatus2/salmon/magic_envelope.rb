module OStatus2
  module Salmon
    # Represents magic envelope
    MagicEnvelope = Struct.new(:body, :sig, :key_id, :type, :encoding, :alg) do
      # XML Namespace of magic envelope
      XMLNS = 'http://salmon-protocol.org/ns/magic-env'

      # @!method initialize(body, sig, key_id, type='application/atom+xml', encoding='base64url', alg='RSA-SHA256')
      # @param [String] body Content of data element or complete magic envelope XML serialization as the only argument
      # @param [String, OpenSSL::PKey::RSA] sig A signature or a RSA key pair to sign
      # @param [String] key_id key_id attribute of alg element
      #   (defaults to a PEM representation of a public key if provided)
      # @param [String] type type attribute of data element
      # @param [String] encoding Content of encoding element
      # @param [String] alg Content of alg element
      # @raise [OStatus2::Salmon::BadError] Error raised if the envelope is malformed
      def initialize(*args)
        if args.size == 1
          xml = Nokogiri::XML(args[0])

          raise BadError if xml.at_xpath('//me:data', me: XMLNS).nil? || xml.at_xpath('//me:data', me: XMLNS).attribute('type').nil? || xml.at_xpath('//me:sig', me: XMLNS).nil? || xml.at_xpath('//me:encoding', me: XMLNS).nil? || xml.at_xpath('//me:alg', me: XMLNS).nil?

          data_element     = xml.at_xpath('//me:data', me: XMLNS)
          sig_element      = xml.at_xpath('//me:sig', me: XMLNS)
          encoding_element = xml.at_xpath('//me:encoding', me: XMLNS)
          alg_element      = xml.at_xpath('//me:alg', me: XMLNS)

          super OStatus2::Salmon::decode_base64url(data_element.content.gsub(/\s+/, '')),
                OStatus2::Salmon::decode_base64url(sig_element.content.gsub(/\s+/, '')),
                sig_element.attribute('key_id')&.value,
                data_element.attribute('type').value,
                encoding_element.content,
                alg_element.content
        else
          args[3] ||= 'application/atom+xml'
          args[4] ||= 'base64url'
          args[5] ||= 'RSA-SHA256'

          if args[1].is_a?(OpenSSL::PKey::RSA)
            key = args[1]
            plaintext = plaintext_sig(args[0], args[3], args[4], args[5])
            args[1] = key.sign(digest, plaintext)
            args[2] ||= OStatus2::Salmon.encode_base64url(key.public_key.to_s)
          end

          super
        end
      end

      # Serialize a magic envelope into XML
      # @return [String] Magic envelope XML serialization
      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml['me'].env({ 'xmlns:me' => XMLNS }) do
            xml['me'].data({ type: type }, OStatus2::Salmon.encode_base64url(body))
            xml['me'].encoding(encoding)
            xml['me'].alg(alg)
            xml['me'].sig({ key_id: key_id }, OStatus2::Salmon.encode_base64url(sig))
          end
        end.to_xml
      end

      # Verify the magic envelope's integrity
      # @param [OpenSSL::PKey::RSA] key The public part of the key will be used
      # @return [Boolean]
      def verify(key)
        plaintext = plaintext_sig(body, type, encoding, alg)
        key.public_key.verify(digest, sig, plaintext)
      rescue BadError
        false
      end

      class << self
        # Represents an error due to malformed magic envelope
        class BadError < OStatus2::Error
        end

        # Deliver the magic envelope XML serialization to a Salmon endpoint
        # @param [String] salmon_url Salmon endpoint URL
        # @param [String] envelope Magic envelope XML serialization
        # @raise [HTTP::Error] Error raised upon delivery failure
        # @raise [OpenSSL::SSL::SSLError] Error raised upon SSL-related failure during delivery
        # @return [HTTP::Response]
        def post_xml(salmon_url, envelope)
          http_client.headers(HTTP::Headers::CONTENT_TYPE => 'application/magic-envelope+xml').post(Addressable::URI.parse(salmon_url), body: envelope)
        end

        private

        def http_client
          HTTP.timeout(:per_operation, write: 60, connect: 20, read: 60)
        end
      end

      private

      def digest
        OpenSSL::Digest::SHA256.new
      end

      def plaintext_sig(data, type, encoding, alg)
        [data, type, encoding, alg].map { |i| OStatus2::Salmon.encode_base64url(i) }.join('.')
      end
    end
  end
end
