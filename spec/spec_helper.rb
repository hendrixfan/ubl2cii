# frozen_string_literal: true

require 'bundler/setup'
require 'ubl2cii'
require 'pry'

module RspecAccessorsHelper
  def file_fixture(name)
    File.read(File.expand_path("../fixtures/#{name}", __FILE__))
  end
end

RSpec.configure do |config|
  # Config options here
  config.include RspecAccessorsHelper

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
