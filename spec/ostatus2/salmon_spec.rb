require 'spec_helper'

describe OStatus2::Salmon do
  describe '.decode_base64url' do
    it 'decodes base64url without paddings' do
      expect(OStatus2::Salmon.decode_base64url('ZGVjb2RlZA')).to eq 'decoded'
    end
  end

  describe '.encode_base64url' do
    it 'encodes a string into base64url' do
      expect(OStatus2::Salmon.encode_base64url('decoded')).to eq 'ZGVjb2RlZA=='
    end
  end
end
