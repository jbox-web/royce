# frozen_string_literal: true

module Royce
  class Engine < ::Rails::Engine

    # Make `royce_roles` available on every model. Hooking `on_load(:active_record)`
    # rather than extending ActiveRecord::Base eagerly defers the extend until AR
    # is actually loaded, so royce imposes no boot-order dependency and stays
    # compatible with Rails' lazy loading.
    initializer 'royce.initialize' do
      ActiveSupport.on_load(:active_record) do
        extend Royce::Macros
      end
    end

  end
end
