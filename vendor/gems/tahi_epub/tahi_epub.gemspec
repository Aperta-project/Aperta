# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tahi_epub/version'

Gem::Specification.new do |spec|
  spec.name          = "tahi_epub"
  spec.version       = TahiEpub::VERSION
  spec.authors       = ["Rizwan Reza"]
  spec.email         = ["rizwanreza@gmail.com"]
  spec.summary       = "Tahi-flavored ePub compressor and extractor with helpful modules used by Tahi and iHat."
  spec.description   = %q{Tahi-flavored ePub compressor and extractor with helpful modules used by Tahi and iHat.}
  spec.homepage      = "http://github.com/tahi-project/tahi_epub"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rubyzip", "~> 1.1"
  spec.add_dependency "activesupport", "~> 4.1"
  spec.add_dependency "net-ssh"
  spec.add_dependency "fog", "~> 1.34"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "dotenv", "~> 1.0.2"
end
