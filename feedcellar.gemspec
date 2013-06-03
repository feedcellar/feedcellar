# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'feedcellar/version'

Gem::Specification.new do |spec|
  spec.name          = "feedcellar"
  spec.version       = Feedcellar::VERSION
  spec.authors       = ["Masafumi Yokoyama"]
  spec.email         = ["myokoym@gmail.com"]
  spec.description   = %q{A searchable storage for RSS feed reader by rroonga.}
  spec.summary       = %q{Searchable Storage for Feed Reader}
  spec.homepage      = "https://github.com/myokoym/feedcellar"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("rroonga")
  spec.add_runtime_dependency("thor")

  spec.add_development_dependency("test-unit")
  spec.add_development_dependency("test-unit-notify")
  spec.add_development_dependency("test-unit-rr")
  spec.add_development_dependency("bundler", "~> 1.3")
  spec.add_development_dependency("rake")
end
