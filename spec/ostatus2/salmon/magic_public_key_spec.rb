require 'spec_helper'

describe OStatus2::Salmon::MagicPublicKey do
  FORMATTED = 'data:application/magic-public-key,RSA.p96gQzu3xrmcEi50ScJnftxcHD5CCKNSY7ckYMVjQ4kquXC0yVSf37v90ylhDH96FIijUesV-dVjhgspBV-nBw==.AQAB'
  N = 8792046075689043363232416638565141340544360030419271972383556104721760666810289531879428170641142438262522893048913367584534393199599425777885589146674951
  E = 65537

  describe '.new' do
    it 'decodes the first argument if it is the only one' do
      expect(OStatus2::Salmon::MagicPublicKey.new(FORMATTED).to_h).to eq({ n: N, e: E })
    end

    it 'sets arguments as modulus and exponent if two are given' do
      expect(OStatus2::Salmon::MagicPublicKey.new(N, E).to_h).to eq({ n: N, e: E })
    end
  end

  describe '#format' do
    it 'formats itself' do
      expect(OStatus2::Salmon::MagicPublicKey.new(N, E).format).to eq FORMATTED
    end
  end
end
