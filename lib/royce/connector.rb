# frozen_string_literal: true

module Royce
  class Connector < ::ActiveRecord::Base

    # Table name — deliberately singular (`royce_connector`, not the Rails-default
    # plural). Kept in sync by hand with the migration template and dummy schema.
    self.table_name = 'royce_connector'

    # Polymorphic join between any roleable model and a Royce::Role. A unique
    # index on (roleable_id, roleable_type, role_id) makes a duplicate assignment
    # raise RecordNotUnique instead of inserting a second row — this is what makes
    # Royce::Methods#add_role idempotent under concurrency.
    belongs_to :roleable, polymorphic: true
    belongs_to :role, class_name: 'Royce::Role'
  end
end
