# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'securer_randomer/version'

Gem::Specification.new do |spec|
  spec.name          = 'securer_randomer'
  spec.version       = SecurerRandomer::VERSION
  spec.authors       = ['Mike Pastore']
  spec.email         = ['mike@oobak.org']

  spec.summary       = 'Monkeypatch SecureRandom with RbNaCl'
  spec.homepage      = 'https://github.com/mwpastore/securer_randomer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split(%r{\x0}).reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 11.1.1'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-given', '~> 3.8.0'
  spec.add_development_dependency 'rubocop', '~> 0.39.0'

  spec.add_runtime_dependency 'rbnacl', '~> 3.3'
end
