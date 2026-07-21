# frozen_string_literal: true

module Royce
  module Macros

    def royce_roles(roles)
      role_strings = roles.map(&:to_s)

      # Expose the declared role names as a class-level attribute.
      # `class_attribute` (unlike a bare class instance variable) is inherited
      # by STI subclasses, so `Admin < User` keeps the roles declared on `User`.
      class_attribute :available_role_names, instance_accessor: false
      self.available_role_names = role_strings

      include Royce::ClassMethods
      include Royce::Methods
      extend  Royce::Schema
    end

  end
end
