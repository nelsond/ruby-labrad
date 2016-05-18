# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'labrad/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby-labrad'
  spec.version       = LabRAD::VERSION
  spec.authors       = ['Nelson Darkwah Oppong']
  spec.email         = ['n@darkwahoppong.com']

  spec.summary       = 'Ruby interface for LabRAD'
  spec.homepage      = 'https://github.com/nelsond/ruby-labrad'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.40'
  spec.add_development_dependency 'irbtools', '~> 2.0'
  spec.add_development_dependency 'simplecov', '~> 0.11'
end
