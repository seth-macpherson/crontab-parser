# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crontab/parser/version'

Gem::Specification.new do |spec|
  spec.name          = "crontab-parser"
  spec.version       = Crontab::Parser::VERSION
  spec.authors       = ["Seth MacPherson", "uu59"]
  spec.email         = ["seth.macpherson@gmail.com","a@tt25.org"]
  spec.description   = %q{Updated crontab-parser}
  spec.summary       = %q{I added a method to identify the next_run of a particular cron job}
  spec.homepage      = "https://github.com/seth-macpherson/crontab-parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end