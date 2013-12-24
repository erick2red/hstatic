# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hstatic/version'

Gem::Specification.new do |spec|
  spec.name          = "hstatic"
  spec.version       = Hstatic::VERSION
  spec.authors       = ["Erick Pérez Castellanos"]
  spec.email         = ["erick.red@gmail.com"]
  spec.description   = %q{Hstatic is a simple HTTP server for your static files.
It's designed for launching it from anywhere in your filesystem tree.
It features a nice directory listing and automatic publishing of your index.html files}
  spec.summary       = %q{An HTTP server for you static files}
  spec.homepage      = "https://github.com/erick2red/hstatic"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "haml"
  spec.add_runtime_dependency "slim"
end
