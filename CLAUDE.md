# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Royce is a Rails gem that adds polymorphic roles to ActiveRecord models. A model
declares its role set with `royce_roles %w[user admin editor]`; the gem then
generates query/mutation/predicate methods on instances, named scopes on the
class, and a reverse association from `Royce::Role` back to the model.

Requires Ruby `>= 3.2.0` and Rails `>= 7.0`.

## Commands

```sh
bin/rspec                        # run the full test suite
bin/rspec spec/royce/role_spec.rb        # run one file
bin/rspec spec/royce/role_spec.rb:96     # run one example by line number
bin/rubocop                      # lint (config in .rubocop.yml)

# Test against a specific Rails version (matrix lives in Appraisals / gemfiles/)
BUNDLE_GEMFILE=gemfiles/rails_8.1.gemfile bin/rspec
```

`bundle exec guard` (see `Guardfile`) reruns specs on file changes.

After editing `Appraisals`, regenerate the pinned gemfiles with `bundle exec appraisal generate`.

## Architecture

`royce_roles` is the single entry point. The wiring is layered — understanding the
order matters because each piece depends on state the previous one installs.

- **`lib/royce/engine.rb`** — on `ActiveSupport.on_load(:active_record)`, extends
  every AR class with `Royce::Macros`. This is why `royce_roles` is available on
  any model without an explicit include.

- **`lib/royce/macros.rb`** — `royce_roles(roles)` is the orchestrator. It stores
  the declared names in the model's singleton `@available_role_names` (exposed via
  a read-only `attr_reader` on the singleton class), then includes/extends the
  three modules below **in order**. Everything downstream reads
  `available_role_names`, so it must be set first.

- **`lib/royce/class_methods.rb`** — included second. Its `self.included` hook adds
  the `role_connectors` / `roles` associations, the `available_roles` class method,
  and one named scope per role (`User.admins`, `Employee.partiers`). It also
  reopens `Royce::Role` to add a `has_many` back to the including model
  (`role.users`, `role.employees`), pluralizing the model name to build the
  association. **Note:** these reverse associations accumulate on `Royce::Role`
  across every model that calls `royce_roles`.

- **`lib/royce/methods.rb`** — included third. Its `self.included` hook defines the
  per-role predicate (`user?`) and bang (`user!`) instance methods. Also provides
  `add_role` / `remove_role` / `has_role?` / `allowed_role?` / `role_list`.
  `add_role` is idempotent and silently no-ops on a role the model doesn't declare
  (guarded by `allowed_role?`).

- **`lib/royce/schema.rb`** — extended onto the model; overrides `load_schema!` to
  `find_or_create_by` a `Royce::Role` row for each declared name the first time the
  model's schema is loaded. This is why roles exist in the DB without a seed step.

- **`lib/royce/role.rb` / `lib/royce/connector.rb`** — the two AR models. Tables are
  the **singular** `royce_role` and `royce_connector` (set explicitly via
  `self.table_name`). `Connector` is the polymorphic join (`roleable`).

Autoloading is Zeitwerk (`lib/royce.rb`), with `lib/generators` explicitly ignored.

## Generator

`bin/rails g royce:install` (`lib/generators/royce/install_generator.rb`) copies
`templates/create_royce.erb` into the host app's `db/migrate/`. The migration
creates the `royce_connector` and `royce_role` tables.

## Testing

Specs run against a full Rails dummy app under `spec/dummy` (models `User`,
`Employee`, `BabyBoomer`). `spec/config_rspec.rb` loads
`spec/dummy/db/schema.rb` fresh before the suite — the DB schema is the
authoritative source, not the migration template, so the two must be kept in
sync manually when the table structure changes. Specs use SQLite and randomized
order; SimpleCov emits HTML + JSON coverage into `coverage/`.

## Conventions

- `# frozen_string_literal: true` on every Ruby file.
- Style deviations from RuboCop defaults are encoded in `.rubocop.yml`
  (hash shorthand `never`, `to_not` over `not_to`, relaxed empty-line layout).
- The version lives in `lib/royce/version.rb` as split `MAJOR`/`MINOR`/`TINY`
  constants, not a single string.
