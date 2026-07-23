# frozen_string_literal: true

# Configure RSpec
RSpec.configure do |config|
  # Use DB agnostic schema by default
  load Rails.root.join('db', 'schema.rb').to_s

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Royce seeds one royce_role row per declared name the first time each model's
  # schema loads (Royce::Schema#load_schema!). Several specs delete role rows via
  # `delete_all` without restoring them, so under randomized order a later spec
  # can observe a depleted `available_roles` and silently exercise less code.
  # Re-seed the declared roles before each example to keep the suite (and its
  # coverage) deterministic regardless of order. The dummy app's royce models are
  # listed explicitly — a full `eager_load!` is avoided as it trips over the
  # dummy's ActiveStorage config.
  config.before do
    [User, Employee, BabyBoomer].each do |model|
      model.available_role_names.each { |name| Royce::Role.find_or_create_by(name: name) }
    end
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!
end
