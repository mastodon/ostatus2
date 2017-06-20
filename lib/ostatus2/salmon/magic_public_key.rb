module OStatus2
  module Salmon
    # Represents public key
    MagicPublicKey = Struct.new(:n, :e) do
      # @!method initialize(n, e)
      # @param [Numeric, String] n Modulus or a magic public key or
      #   public key in application/magic-key format as the only argument
      # @param [Numeric] e Exponent
      def initialize(*args)
        if args.size == 1
          _, modulus, exponent = args[0].split('.')
          decoded = [modulus, exponent].map { |n| OStatus2::Salmon.decode_base64url(n).bytes.inject(0) { |a, e| (a << 8) | e } }
          super *decoded
        else
          super
        end
      end

      # Format itself into application/magic-key format
      # @return [String] Public key in application/magic-key format
      def format
        encoded = [n, e].map do |component|
          result = []

          until component.zero?
            result << [component % 256].pack('C')
            component >>= 8
          end

          OStatus2::Salmon.encode_base64url(result.reverse.join)
        end

        (['data:application/magic-public-key,RSA'] + encoded).join('.')
      end
    end
  end
end
