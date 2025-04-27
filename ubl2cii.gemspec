# frozen_string_literal: true

require_relative 'lib/ubl2_cii/version'

Gem::Specification.new do |spec|
  spec.name          = 'ubl2cii'
  spec.version       = Ubl2Cii::VERSION
  spec.authors       = ['Wolfgang Fournes']
  spec.email         = ['w.wohanka@gmail.com']

  spec.summary       = 'A Ruby Gem to convert UBL XML files to CII XML files'
  spec.description   = 'This Gem provides a simple way to convert UBL XML files to CII XML files.'
  spec.homepage      = 'https://rubygems.org/gems/ubl2cii'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = 'bin'
  spec.executables   = ['console']
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '>= 1.18'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
