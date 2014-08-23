# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'feedcellar/version'

Gem::Specification.new do |spec|
  spec.name          = "feedcellar"
  spec.version       = Feedcellar::VERSION
  spec.authors       = ["Masafumi Yokoyama"]
  spec.email         = ["myokoym@gmail.com"]
  spec.description   = %q{Feedcellar is a full-text searchable RSS feed reader and data store by Groonga (via Rroonga) with Ruby.}
  spec.summary       = %q{Full-Text Searchable RSS Feed Reader by Groonga}
  spec.homepage      = "http://myokoym.net/feedcellar/"
  spec.license       = "LGPLv2.1 or later"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("rroonga", ">= 3.0.4")
  spec.add_runtime_dependency("thor")
  #spec.add_runtime_dependency("gtk2")
  spec.add_runtime_dependency("sinatra")
  spec.add_runtime_dependency("haml")
  spec.add_runtime_dependency("launchy")
  spec.add_runtime_dependency("racknga")

  spec.add_development_dependency("test-unit")
  spec.add_development_dependency("test-unit-notify")
  spec.add_development_dependency("test-unit-rr")
  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
end
