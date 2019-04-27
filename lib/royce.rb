# frozen_string_literal: true

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
generators = "#{__dir__}/generators"
loader.ignore(generators)
loader.setup

module Royce
  require 'royce/engine' if defined?(Rails)
end
