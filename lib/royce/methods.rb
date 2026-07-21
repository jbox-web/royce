# frozen_string_literal: true

module Royce
  module Methods

    # Called when module included in a class
    # includer == User
    # includer.class == Class
    def self.included(includer)
      # With instance eval, we can add instance methods
      # Add instance methods like user? admin?
      includer.instance_eval do
        # Loop through all available role names
        # and add a name? method that queries the has_role? method
        available_role_names.each do |name|
          define_method(:"#{name}?") do
            has_role? name
          end

          define_method(:"#{name}!") do
            add_role name
          end
        end
      end
    end

    # These methods are included in all User instances

    # Returns true when the role is (or already was) assigned, false when the
    # role is not allowed for this class.
    def add_role(name)
      return false unless allowed_role?(name)
      return true if has_role?(name)

      role = name.is_a?(Royce::Role) ? name : Role.find_or_create_by(name: name.to_s)
      roles << role
      true
    rescue ActiveRecord::RecordNotUnique
      # A concurrent request inserted the same connector first. The unique index
      # on royce_connector makes this a no-op rather than a duplicate row.
      true
    end

    # Returns true when a role was removed (or was already absent for an allowed
    # role), false when the role is not allowed for this class.
    def remove_role(name) # rubocop:disable Naming/PredicateMethod
      return false unless allowed_role?(name)

      role = name.is_a?(Royce::Role) ? name : Role.find_by(name: name.to_s)
      roles.delete(role) if role
      true
    end

    def has_role?(name) # rubocop:disable Naming/PredicatePrefix
      roles.where(name: name.to_s).exists?
    end

    def allowed_role?(name)
      self.class.available_role_names.include?(name.to_s)
    end

    def role_list
      roles.pluck(:name)
    end

  end
end
