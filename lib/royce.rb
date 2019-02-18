# frozen_string_literal: true

require 'active_record'

require 'zeitwerk'
Zeitwerk::Loader.for_gem.setup

module Royce
  # Every ::ActiveRecord::Base now includes Royce::Macros
  # This gives them access to the royce_roles method
  ::ActiveRecord::Base.send(:include, Royce::Macros)
end
