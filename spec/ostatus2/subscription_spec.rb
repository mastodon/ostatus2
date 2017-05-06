require 'spec_helper'

describe OStatus2::Subscription do
  let(:secret)  { '789123'}
  let(:hub)     { 'http://hub.example.com' }
  let(:topic)   { 'http://example.com/topic' }
  let(:webhook) { 'http://example.com/callback'}

  subject { OStatus2::Subscription.new(topic, secret: secret, webhook: webhook, hub: hub) }

  describe '#subscribe' do
    before do
      stub_request(:post, hub).to_return(status: 202, body: '')
      @response = subject.subscribe
    end

    it 'sends a subscription request to the specified hub' do
      expect(a_request(:post, hub).with(body: { 'hub.topic' => topic, 'hub.mode' => 'subscribe', 'hub.callback' => webhook, 'hub.lease_seconds' => '', 'hub.secret' => secret, 'hub.verify' => 'async' })).to have_been_made
    end

    it 'returns a subscription response' do
      expect(@response).to be_a HTTP::Response
    end

    it 'returns a successful response' do
      expect(@response.code).to eq 202
    end
  end

  describe '#unsubscribe' do
    before do
      stub_request(:post, hub).to_return(status: 202, body: '')
      @response = subject.unsubscribe
    end

    it 'sends a subscription termination request to the specified hub' do
      expect(a_request(:post, hub).with(body: { 'hub.topic' => topic, 'hub.mode' => 'unsubscribe', 'hub.callback' => webhook, 'hub.lease_seconds' => '', 'hub.secret' => secret, 'hub.verify' => 'async' })).to have_been_made
    end

    it 'returns a subscription response' do
      expect(@response).to be_a HTTP::Response
    end

    it 'returns a successful response' do
      expect(@response.code).to eq 202
    end
  end

  describe '#valid?' do
    it 'returns true when the provided topic matches' do
      expect(subject.valid?(topic)).to be true
    end

    it 'returns false when the topic is wrong' do
      expect(subject.valid?('bad topic')).to be false
    end
  end

  describe '#verify' do
    let(:content) { 'foo bar' }
    it 'returns true when the signature matches the contents' do
      hash      = OpenSSL::HMAC.hexdigest('sha1', secret, content)
      signature = "sha1=#{hash}"

      expect(subject.verify(content, signature)).to be true
    end

    it 'returns true when the signature is coming in as uppercase and matches the contents' do
      hash      = OpenSSL::HMAC.hexdigest('sha1', secret, content).upcase
      signature = "sha1=#{hash}"

      expect(subject.verify(content, signature)).to be true
    end

    it 'returns false when the contents were signed with a different secret' do
      hash      = OpenSSL::HMAC.hexdigest('sha1', 'other secret', content)
      signature = "sha1=#{hash}"

      expect(subject.verify(content, signature)).to be false
    end
  end
end
