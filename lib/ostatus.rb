require 'base64'
require 'openssl'
require 'http'
require 'addressable'
require 'nokogiri'

require 'ostatus/version'
require 'ostatus/publication'
require 'ostatus/subscription'
require 'ostatus/salmon'

module OStatus
  class Error < StandardError
  end

  class BadSalmonError < Error
  end
end
