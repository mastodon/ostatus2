require 'ostatus2/salmon/magic_envelope'
require 'ostatus2/salmon/magic_public_key'

module OStatus2
  # Provides features related to Salmon, conforming to draft-panzer-magicsig-00
  module Salmon
    class << self
      # Decode base64url, adding paddings if missing due to conformance with an obsolete specification
      # @param [String] string String encoded with base64url, possibly missing paddings
      # @return [String] Decoded string
      def decode_base64url(string)
        retries = 0

        begin
          return Base64::urlsafe_decode64(string)
        rescue ArgumentError
          retries += 1
          string = "#{string}="
          retry unless retries > 2
        end
      end

      # Encode base64url (provided for symmetry with decode_base64url.
      # see Base64.urlsafe_encode64.)
      # @param (see Base64.urlsafe_encode64)
      # @raise (see Base64.urlsafe_encode64)
      # @return (see Base64.urlsafe_encode64)
      def encode_base64url(*args)
        Base64.urlsafe_encode64 *args
      end
    end
  end
end
