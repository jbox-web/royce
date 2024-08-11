# frozen_string_literal: true

require_relative 'lib/royce/version'

Gem::Specification.new do |s|
  s.name        = 'royce'
  s.version     = Royce::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Martin Nash', 'Nicolas Rodriguez']
  s.email       = ['martin.j.nash@gmail.com', 'nico@nicoladmin.fr']
  s.homepage    = 'https://github.com/jbox-web/royce'
  s.summary     = 'A Rails roles solution.'
  s.description = 'Roles.'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.1.0'

  s.files = `git ls-files`.split("\n")

  s.add_dependency 'rails', '>= 7.0'
  s.add_dependency 'zeitwerk'
end
