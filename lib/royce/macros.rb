# frozen_string_literal: true

module Royce
  module Macros

    def royce_roles(roles)
      role_strings = roles.map(&:to_s)

      # Work in singleton class
      # Add a read-only class variable to all classes that call `royce_roles`
      class << self
        attr_reader :available_role_names
      end
      @available_role_names = role_strings

      include Royce::ClassMethods
      include Royce::Methods
      extend  Royce::Schema
    end

  end
end
