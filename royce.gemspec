# frozen_string_literal: true

require_relative 'lib/royce/version'

Gem::Specification.new do |s|
  s.name        = 'royce'
  s.version     = Royce::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Martin Nash', 'Nicolas Rodriguez']
  s.email       = ['martin.j.nash@gmail.com', 'nicoladmin@free.fr']
  s.homepage    = 'https://github.com/jbox-web/royce'
  s.summary     = 'A Rails roles solution.'
  s.description = 'Roles.'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.6.0'

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'rails', '>= 5.2'
  s.add_runtime_dependency 'zeitwerk'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3', '~> 1.4.0'
end
