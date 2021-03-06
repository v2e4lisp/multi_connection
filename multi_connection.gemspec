# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_connection/version'

Gem::Specification.new do |spec|
  spec.name          = "multi_connection"
  spec.version       = MultiConnection::VERSION
  spec.authors       = ["wenjun.yan"]
  spec.email         = ["mylastnameisyan@gmail.com"]
  spec.summary       = %q{rails multiple database connections}
  spec.description   = %q{rails multiple database connections}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "sqlite3"

  spec.add_dependency "activerecord", ">= 4.0.0"
  spec.add_dependency "thread_safe"
end
