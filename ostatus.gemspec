# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ostatus/version'

Gem::Specification.new do |spec|
  spec.name          = "ostatus"
  spec.version       = OStatus::VERSION
  spec.authors       = ["Eugen Rochko"]
  spec.email         = ["eugen@zeonfederated.com"]

  spec.summary       = "A gem for dealing with the OStatus specification"
  spec.description   = "A gem for dealing with the OStatus specification"
  spec.homepage      = "https://github.com/Gargron/ostatus"
  spec.license       = "MIT"

  spec.files         = `git ls-files lib LICENSE README.md`.split($RS)
  spec.require_paths = ["lib"]

  spec.add_dependency('http', '~> 1.0')
  spec.add_dependency('addressable', '~> 2.4')

  spec.add_development_dependency "bundler", "~> 1.8"
end
