# frozen_string_literal: true

module Royce
  module Schema

    def load_schema!
      super

      # `load_schema!` runs during schema introspection (first column access).
      # Guard the write so booting against an unmigrated database (migrations,
      # assets:precompile) or a read-only connection does not crash: the role
      # rows are created on the next schema load once the table exists.
      return unless connection.table_exists?(Royce::Role.table_name)

      (available_role_names || []).each do |name|
        Role.find_or_create_by(name: name)
      end
    rescue ActiveRecord::StatementInvalid
      nil
    end

  end
end
