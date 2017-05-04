# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ostatus2/version'

Gem::Specification.new do |spec|
  spec.name          = "ostatus2"
  spec.version       = OStatus2::VERSION
  spec.authors       = ["Eugen Rochko"]
  spec.email         = ["eugen@zeonfederated.com"]

  spec.summary       = "Toolset for interacting with the OStatus2 suite of protocols"
  spec.description   = "Toolset for interacting with the OStatus2 suite of protocols"
  spec.homepage      = "https://github.com/tootsuite/ostatus2"
  spec.license       = "MIT"

  spec.files         = `git ls-files lib LICENSE README.md`.split($RS)
  spec.require_paths = ["lib"]

  spec.add_dependency('openssl', '~> 2.0')
  spec.add_dependency('http', '~> 2.0')
  spec.add_dependency('addressable', '~> 2.4')
  spec.add_dependency('nokogiri', '~> 1.6')

  spec.add_development_dependency 'bundler', '~> 1.3'
end
