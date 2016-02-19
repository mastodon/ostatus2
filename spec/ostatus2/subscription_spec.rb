require 'spec_helper'

describe OStatus2::Subscription do
  let(:token)   { '123456'}
  let(:secret)  { '789123'}
  let(:hub)     { 'http://hub.example.com' }
  let(:topic)   { 'http://example.com/topic' }
  let(:webhook) { 'http://example.com/callback'}

  subject { OStatus2::Subscription.new(topic, token: token, secret: secret, webhook: webhook, hub: hub) }

  describe '#subscribe' do
    before do
      stub_request(:post, hub).to_return(status: 200, body: '')
      subject.subscribe
    end

    it 'sends a subscription request to the specified hub' do
      expect(a_request(:post, hub).with(body: { 'hub.topic' => topic, 'hub.mode' => 'subscribe', 'hub.callback' => webhook, 'hub.verify_token' => token, 'hub.secret' => secret, 'hub.lease_seconds' => '', 'hub.verify' => 'async' })).to have_been_made
    end
  end

  describe '#unsubscribe' do
    before do
      stub_request(:post, hub).to_return(status: 200, body: '')
      subject.unsubscribe
    end

    it 'sends a subscription termination request to the specified hub' do
      expect(a_request(:post, hub).with(body: { 'hub.topic' => topic, 'hub.mode' => 'unsubscribe', 'hub.callback' => webhook, 'hub.verify_token' => token, 'hub.secret' => secret, 'hub.lease_seconds' => '', 'hub.verify' => 'async' })).to have_been_made
    end
  end

  describe '#valid?' do
    it 'returns true when the provided token and topic match' do
      expect(subject.valid?(topic, token)).to be true
    end

    it 'returns false when the token is wrong' do
      expect(subject.valid?(topic, 'bad token')).to be false
    end

    it 'returns false when the topic is wrong' do
      expect(subject.valid?('bad topic', token)).to be false
    end
  end

  describe '#verify' do
    let(:content) { 'foo bar' }
    it 'returns true when the signature matches the contents' do
      hash      = OpenSSL::HMAC.hexdigest('sha1', secret, content)
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
