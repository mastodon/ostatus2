module OStatus2
  module MagicKey
    def magic_key_to_pem(magic_key)
      _, modulus, exponent = magic_key.split('.')
      modulus, exponent = [modulus, exponent].map { |n| decode_base64(n).bytes.inject(0) { |a, e| (a << 8) | e } }

      key   = OpenSSL::PKey::RSA.new
      key.n = modulus
      key.e = exponent

      key.to_pem
    end

    def decode_base64(string)
      retries = 0

      begin
        return Base64::urlsafe_decode64(string)
      rescue ArgumentError
        retries += 1
        string = "#{string}="
        retry unless retries > 2
      end
    end
  end
end
