# frozen_string_literal: true

require 'spec_helper'

# `Royce::Schema#load_schema!` seeds a `Royce::Role` row per declared name the
# first time a model's schema is loaded. Both guards below protect a degraded
# boot (unmigrated / read-only DB) and never fire in a nominal run, so they are
# exercised here by forcing the failing condition.
RSpec.describe Royce::Schema do

  it 'skips role creation when the roles table does not exist' do
    allow(User.connection).to receive(:table_exists?)
      .with(Royce::Role.table_name).and_return(false)

    expect { User.send(:load_schema!) }.to_not change(Royce::Role, :count)
  end

  it 'swallows StatementInvalid raised while seeding role rows' do
    allow(Royce::Role).to receive(:find_or_create_by)
      .and_raise(ActiveRecord::StatementInvalid)

    expect { User.send(:load_schema!) }.to_not raise_error
  end

end
