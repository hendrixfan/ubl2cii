# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'ubl2cii'
  spec.version       = '0.1.0'
  spec.authors       = ['Your Name']
  spec.email         = ['your.email@example.com']

  spec.summary       = 'A Ruby Gem to convert UBL XML files to CII XML files'
  spec.description   = 'This Gem provides a simple way to convert UBL XML files to CII XML files.'
  spec.homepage      = 'https://rubygems.org/gems/ubl2cii'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = 'bin'
  spec.executables   = ['console']
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '>= 1.18'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
