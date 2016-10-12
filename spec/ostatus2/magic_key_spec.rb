require 'spec_helper'

describe OStatus2::MagicKey do
  subject { Class.new { extend OStatus2::MagicKey } }

  describe '#magic_key_to_pem' do
    let(:magic_key) { 'data:application/magic-public-key,RSA.AKfeoEM7t8a5nBIudEnCZ37cXBw-QgijUmO3JGDFY0OJKrlwtMlUn9-7_dMpYQx_ehSIo1HrFfnVY4YLKQVfpwc.AQAB' }

    it 'returns a pem key' do
      expect(subject.magic_key_to_pem(magic_key)).to be_a String
    end
  end

  describe '#decode_base64' do
    it 'decodes padding-stripped base64' do
      expect(subject.decode_base64('SGVsbG8gd29ybGQsIEkgYW0gZG9vbSwgYnJpbmdlciBvZiBiYWQgQmFzZTY0IGFuZCBiaWcgbnVtYmVycyBsaWtlIDk5OTI4ODg3MjM2NzY3ODI4Mg')).to eq 'Hello world, I am doom, bringer of bad Base64 and big numbers like 999288872367678282'
    end

    it 'decodes normal urlsafe base64' do
      expect(subject.decode_base64(Base64.urlsafe_encode64('Hello world'))).to eq 'Hello world'
    end
  end
end
