# frozen_string_literal: true

# require external dependencies
require 'zeitwerk'

# load zeitwerk
Zeitwerk::Loader.for_gem.tap do |loader|
  loader.ignore("#{__dir__}/generators")
  loader.setup
end

module Royce
  require_relative 'royce/engine' if defined?(Rails)
end
