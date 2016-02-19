require 'spec_helper'

describe OStatus::Publication do
  let(:hubs) { ['http://hub1.example.com', 'http://hub2.example.com'] }

  before do
    hubs.each { |h| stub_request(:post, h).to_return(status: 200, body: '') }
  end

  describe '#publish' do
    subject { OStatus::Publication.new('http://example.com/feed', hubs) }

    before do
      subject.publish
    end

    it 'notifies all hubs about a given topic URL' do
      hubs.each { |h| expect(a_request(:post, h).with(body: { "hub.mode" => "publish", "hub.url" => "http://example.com/feed" })).to have_been_made }
    end
  end
end
