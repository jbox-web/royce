# frozen_string_literal: true

module Royce
  class Role < ::ActiveRecord::Base

    # Table name
    self.table_name = 'royce_role'

    # Relations
    has_many :connectors, class_name: 'Royce::Connector'

    def to_s
      name
    end
  end
end
