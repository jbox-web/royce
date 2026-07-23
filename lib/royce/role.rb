# frozen_string_literal: true

module Royce
  class Role < ::ActiveRecord::Base

    # Table name — deliberately singular (`royce_role`, not the Rails-default
    # plural). Kept in sync by hand with the migration template and the dummy
    # schema; `royce_role.name` carries a unique index.
    self.table_name = 'royce_role'

    # Relations.
    # The per-model reverse associations (`role.users`, `role.employees`) are
    # NOT declared here: Royce::ClassMethods reopens this class and adds one
    # `has_many` for every model that calls `royce_roles`.
    has_many :connectors, class_name: 'Royce::Connector'

    def to_s
      name
    end
  end
end
