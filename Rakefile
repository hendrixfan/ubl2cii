require 'rubygems'
require 'bundler/setup'

require 'rake/testtask'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task default: :spec

RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = '-w'
  t.rspec_opts = %w(--backtrace --color)
end
