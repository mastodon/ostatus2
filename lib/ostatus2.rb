require 'base64'
require 'openssl'
require 'http'
require 'addressable'
require 'nokogiri'

module OStatus2
  class Error < StandardError
  end
end

require 'ostatus2/version'
require 'ostatus2/publication'
require 'ostatus2/subscription'
require 'ostatus2/salmon'
