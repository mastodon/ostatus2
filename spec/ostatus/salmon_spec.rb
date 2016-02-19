require 'spec_helper'

describe OStatus::Salmon do
  let(:url)  { 'http://example.com/salmon' }
  let(:body) { 'Lorem ipsum dolor sit amet' }
  let(:key)  { OpenSSL::PKey::RSA.new 2048 }

  subject { OStatus::Salmon.new }

  describe '#pack' do
    it 'returns a magical envelope' do
      xml = Nokogiri::XML(subject.pack(body, key))

      expect(xml.at_xpath('//me:data')).to_not be_nil
      expect(xml.at_xpath('//me:sig')).to_not be_nil
      expect(xml.at_xpath('//me:alg')).to_not be_nil
      expect(xml.at_xpath('//me:encoding')).to_not be_nil
    end
  end

  describe '#post' do
    let(:envelope) { subject.pack(body, key) }

    before do
      stub_request(:post, url)
      subject.post(url, envelope)
    end

    it 'sends the envelope to the Salmon endpoint' do
      expect(a_request(:post, url).with(body: envelope)).to have_been_made
    end
  end

  describe '#unpack' do
    let(:envelope) { subject.pack(body, key) }

    it 'returns the original body' do
      expect(subject.unpack(envelope)).to eql body
    end
  end

  describe '#verify' do
    let(:envelope) { subject.pack(body, key) }

    it 'returns true if the signature is correct' do
      expect(subject.verify(envelope, key)).to be true
    end

    it 'returns false if the signature cannot be verified' do
      expect(subject.verify(envelope, OpenSSL::PKey::RSA.new(2048))).to be false
    end
  end
end
