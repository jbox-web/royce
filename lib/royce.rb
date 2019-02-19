# frozen_string_literal: true

require 'zeitwerk'
Zeitwerk::Loader.for_gem.setup

module Royce
  require 'royce/engine' if defined?(Rails)
end
