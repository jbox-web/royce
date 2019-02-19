# frozen_string_literal: true

module Royce
  class Connector < ::ActiveRecord::Base

    # Table name
    self.table_name = 'royce_connector'

    # Relations
    belongs_to :roleable, polymorphic: true
    belongs_to :role, class_name: 'Royce::Role'
  end
end
