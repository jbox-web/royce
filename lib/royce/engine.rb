# frozen_string_literal: true

module Royce
  class Engine < ::Rails::Engine

    initializer 'royce.initialize' do
      ActiveSupport.on_load(:active_record) do
        extend Royce::Macros
      end
    end

  end
end
