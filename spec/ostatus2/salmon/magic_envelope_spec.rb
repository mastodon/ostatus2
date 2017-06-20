require 'spec_helper'

describe OStatus2::Salmon::MagicEnvelope do
  let(:url)  { 'http://example.com/salmon' }
  let(:body) { 'Lorem ipsum dolor sit amet' }
  let(:key)  { OpenSSL::PKey::RSA.new 2048 }

  subject { OStatus2::Salmon::MagicEnvelope.new(body, key) }

  describe '.new' do
    it 'decodes the first argument if it is the only one' do
      encoded = <<XML
<?xml version="1.0"?>
<me:env xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <me:data type="application/atom+xml">TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQ=</me:data>
  <me:encoding>base64url</me:encoding>
  <me:alg>RSA-SHA256</me:alg>
  <me:sig key_id="LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUE1bGVia0RXRmpTYU96NzdKZ3RtMgoyL250K090Tlh4ZEZWNmdjZUJERVdBYi8ybER0dHp5WE1mTEQ3NTFpdmVielA1Rld4aWt0NW5UWHdId29kOXE2Ck03dFZzSXdNSWU5NGhoSk92b3RSQ1g0SUp0NG5LeWM2UXlYU2JtYWZBZUJWUzZFVG9ZbmY1c0dlR0J6Z2VJTFUKdVh6L0t6bVMyaXRhYVUrS2tiNVdIdGNGQ3lrNDVhMDRWbms0RGdUMnRmWUMxM3ZhM1BhK2xPZlpuNzRDNTdLMwpzQ3U1amwvSG80OWkyV1dBbTRoT1JIZFF6TTF4a2UzR2JLZDB5V00yMXpmU0NacTI0dE5Jd09lcUpHNmpwb0FGCkVHejU2TnhLSmZWbDdkQmYrT01OVTN2MFJab1R0SzBoQkh6cEdvR0MrVnVlNm04eXQwY2Y3ZnpqUzlLQmdsQncKYXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==">5ZwAIoos-jOB04CCVcs6zja5QUs3N32R7gxLiQJeZY9oZe4goVshI2QQne17BuoyZNsuN09pf0YA_J-1T3R92l0rWvfkYa0FVycehKCrYr67Zk-pwb8ww3J3pjM8dqz4pjk1jcyNEVcIQtwomMT3Z9wNI8DKAezNpEDdKOe-bM2ZXg_w1qTBQNa5ZFWCQ8Spc_g7uX_1GX9X0xexbJ4lvTPxRPtPU4I-u3gHP5YjHXxbRiqEFipjMklqZILsCRVlk7tFwteS3mmYW_9BkNu1YADkV0BfCrg2GShyeWrjOXR-krflLxkl4Bxn6T-NHlzD8vOnxcWXvNlXOChl7md_GQ==</me:sig>
</me:env>
XML

      envelope = OStatus2::Salmon::MagicEnvelope.new(encoded)

      expect(envelope.body).to eq 'Lorem ipsum dolor sit amet'
    end

    it 'decodes the first argument if it is the only one even if it lacks key_id' do
      encoded = <<XML
<?xml version="1.0"?>
<me:env xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <me:data type="application/atom+xml">TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQ=</me:data>
  <me:encoding>base64url</me:encoding>
  <me:alg>RSA-SHA256</me:alg>
  <me:sig>5ZwAIoos-jOB04CCVcs6zja5QUs3N32R7gxLiQJeZY9oZe4goVshI2QQne17BuoyZNsuN09pf0YA_J-1T3R92l0rWvfkYa0FVycehKCrYr67Zk-pwb8ww3J3pjM8dqz4pjk1jcyNEVcIQtwomMT3Z9wNI8DKAezNpEDdKOe-bM2ZXg_w1qTBQNa5ZFWCQ8Spc_g7uX_1GX9X0xexbJ4lvTPxRPtPU4I-u3gHP5YjHXxbRiqEFipjMklqZILsCRVlk7tFwteS3mmYW_9BkNu1YADkV0BfCrg2GShyeWrjOXR-krflLxkl4Bxn6T-NHlzD8vOnxcWXvNlXOChl7md_GQ==</me:sig>
</me:env>
XML

      envelope = OStatus2::Salmon::MagicEnvelope.new(encoded)

      expect(envelope.key_id).to eq nil
    end

    it 'sets default values for missing arguments if the number of given arguments is not 1' do
      envelope = OStatus2::Salmon::MagicEnvelope.new

      expect(envelope.type).to eq 'application/atom+xml'
      expect(envelope.encoding).to eq 'base64url'
      expect(envelope.alg).to eq 'RSA-SHA256'
    end

    it 'signs if the second argument is a RSA key pair' do
      key = OpenSSL::PKey::RSA.new <<PEM
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA42kzbqMaTJCt1yD6G2RGnNC1IBkDwSDAarpSigz8Ez0w8lMm
PG2OsSTLbWek7cUoM1kpak+PFC7nJUt73NsW3/9Rnqp0lTo3QqOFIUXepoCJVIe/
PGmHp8Rs68/LwlCl4fUQVadYpxJr2RbgQBEdqncWaGQj9jR3ZSLyAfABdJG4HnYW
LN4Pw6LrwzuvrcPEue0obfLsDYp1NPDWzoxGokEE7/uncEue/sHyyavih26BQEOi
K8d0YFHmXAQ/WUS/azfkRuzYq4mPb7Gm5k9cLxTYD+TZlBtmW+iMF1XetMOEKww7
ERklxLLbv1A1EFiu0kWD9THTfubyJ/PFSEfjrQIDAQABAoIBAQC1KcyoWdUMo8Fp
fULh6Wt7Z6SzUlo0U5QWMiKpCZkS9o90rJrsTtb69fX9TTENnh/dcC1XHNQ93vOT
OWQOWJcLkUmDXgWMEBmPw9a93/x0pjdBGPdW+Dbyhr/CyAJp5XeQ33rI0Y0FY954
zgmN4FTCxSYbuZMQg1GOR12F/54ZLrB+LH0sfdHFsP4SGE/q2VpcU7e+PiLKJy9R
zTMSvQJ2WoDNyWjZfNdGXnPUWR1uhoTg7+vP5cGYWY1UQrr7+qoprNootGc74Y1m
r6ZaMUt/lwGCR/tNodM+XNNsF78+POSIqUq8NQm9vlym83hwMge0N6Xe/aQNC1wM
4ZYdpMkhAoGBAPYHYtNIuKxrQMM9G93ziJhsivOioxLMqUJGhip3CaAO08HINA1I
XUiswTsI48DqvrUb30OITnS1B676ep4EPOw7sYtNkd5eqKoeXVx8nAtSWIzC2Kb7
UMGLFXLm74z1u8qRKcx+a8FefqpXLGTrJ0C/MQtY+KYjPa8ca4Q6aJJFAoGBAOyg
pi8j+SYJMfbY8zucKtG9Fj4t7xhfgtsWZ/FRXbPry6WBeJiRWt6ZQAYyuLxdOP8i
jKRsmKSD063QIL71sPEC3CSCmlMdF2AvZc9q5MmX9BgQcww/3kwQVm0nne6DC+2l
zPBCfR0mQi9t4FD33nNkuqkcem+YJGjYDHQwt1ZJAoGARcyIpAqwofH3uKxAmLJ7
4UqCDWbpvu6jYnMhozCMYYVzXDnRUqdiF7kzRO1buCKhIj6bE8y6/W9Sk7jqSqRH
KHoy/6NtK9pNHZ5pvFB58NhW2PB6iL0qBw7Pcf7EnYgl0+1lH2gKaBzH8Mm0hZkV
VNApON/wAypiWKjGdAgiHMUCgYA/eHv7CxAqdq7zQpBDvgjyR2Du/s0yYXQtJh5t
aWDUAPyYAVmCuwJ/0OWOhA5vYCYIsZC+De8HueCOr9QIxMhYbWb1WB7jCluZzjzl
3QtPU7YCum7Rq1QKXRuBne3L61TIwv9strjul7OLG1LfBQ2jMDKtZ9kjk9C4WrNE
e0jCGQKBgDKAGbBl0BuJ5v5m/CWr1NKqBWTS1/DHs9YsaKfOFKPYCej1MYPtFxfT
X+dywVDYSVWsHgHwwDbgkVQI4qs9ZYlCa/LiKkSaLgBpNnQU9zFN37fwDIWHbcBI
9xRZALsuBZN1L572bEMs2ugpeoU1C2Up+u4Qp8K1QftvkJga29YJ
-----END RSA PRIVATE KEY-----
PEM

      envelope = OStatus2::Salmon::MagicEnvelope.new(body, key)

      expect(Base64.encode64(envelope.sig)).to eq <<BASE64
TUhIGaTJdHglE5Ww0oKqEpjLb7PWFOa7h6aTuPUkjMm9GWPbADINRB5oUj9G
jTk8HRxloX+VmIpRn8IRbLhfdZw9qpx0z5ilYnndiGcu5qRjooXSvR9hURxu
4WoJxyBOG0Lw1c5HzT8EP4qvVWiZe0RHBvYFOpNzR1az+qZVcrnW68u57EdO
PQANP63+NgCBMcvx9HwlAFfxqgrZ1+c1xRKt6gx06F7r0qeD/ubvJ6ezqVu6
bd0YLYLvrGcOulLKakc1gQRfzOGRx/SVBJ+Fiy1OtwunY7dDG4M6ld8NkHvr
EsA6ToEVthX297uBjValeuPx7eeigm0QMKgCQ2FUFA==
BASE64

      expect(envelope.key_id).to eq 'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUE0Mmt6YnFNYVRKQ3QxeUQ2RzJSRwpuTkMxSUJrRHdTREFhcnBTaWd6OEV6MHc4bE1tUEcyT3NTVExiV2VrN2NVb00xa3BhaytQRkM3bkpVdDczTnNXCjMvOVJucXAwbFRvM1FxT0ZJVVhlcG9DSlZJZS9QR21IcDhSczY4L0x3bENsNGZVUVZhZFlweEpyMlJiZ1FCRWQKcW5jV2FHUWo5alIzWlNMeUFmQUJkSkc0SG5ZV0xONFB3Nkxyd3p1dnJjUEV1ZTBvYmZMc0RZcDFOUERXem94Rwpva0VFNy91bmNFdWUvc0h5eWF2aWgyNkJRRU9pSzhkMFlGSG1YQVEvV1VTL2F6ZmtSdXpZcTRtUGI3R201azljCkx4VFlEK1RabEJ0bVcraU1GMVhldE1PRUt3dzdFUmtseExMYnYxQTFFRml1MGtXRDlUSFRmdWJ5Si9QRlNFZmoKclFJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg=='
    end
  end

  describe '#to_xml' do
    it 'serializes itself into a XML' do
      xml = Nokogiri::XML(subject.to_xml)

      expect(xml.at_xpath('//me:data')).to_not be_nil
      expect(xml.at_xpath('//me:sig')).to_not be_nil
      expect(xml.at_xpath('//me:alg')).to_not be_nil
      expect(xml.at_xpath('//me:encoding')).to_not be_nil
    end
  end

  describe '#verify' do
    it 'returns true if the signature is correct' do
      expect(subject.verify(key)).to be true
    end

    it 'returns false if the signature cannot be verified' do
      expect(subject.verify(OpenSSL::PKey::RSA.new(2048))).to be false
    end
  end

  describe '.post_xml' do
    let(:xml) { subject.to_xml }

    before do
      stub_request(:post, url)
      OStatus2::Salmon::MagicEnvelope.post_xml(url, xml)
    end

    it 'sends the XML to the Salmon endpoint' do
      expect(a_request(:post, url).with(body: xml)).to have_been_made
    end
  end
end
