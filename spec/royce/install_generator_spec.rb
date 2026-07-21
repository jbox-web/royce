# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'fileutils'
require 'stringio'
require 'generators/royce/install_generator'

RSpec.describe Royce::InstallGenerator do

  let(:destination) { Dir.mktmpdir }

  after { FileUtils.remove_entry(destination) if File.directory?(destination) }

  def generated_migration
    silence_stream { described_class.start([], destination_root: destination) }
    path = Dir[File.join(destination, 'db/migrate/*_create_royce.rb')].first
    File.read(path) if path
  end

  # Suppress the generator's Thor "create ..." status output during specs.
  def silence_stream
    original = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original
  end

  it 'generates a migration file' do
    expect(generated_migration).to_not be_nil
  end

  it 'targets a specific Active Record release' do
    # A bare `ActiveRecord::Migration` (no [x.y]) is rejected by Rails >= 5.
    expect(generated_migration).to match(/ActiveRecord::Migration\[\d+\.\d+\]/)
  end

  it 'defines a migration class that loads without error' do
    content = generated_migration
    # Loading a directly-inherited migration raises at class definition; the
    # versioned form must not. Evaluate in an anonymous module to avoid leaking
    # the CreateRoyce constant between runs.
    expect { Module.new.module_eval(content) }.to_not raise_error
  end

  it 'declares unique indexes to prevent duplicate roles and assignments' do
    content = generated_migration
    expect(content).to include('t.index :name, unique: true')
    expect(content).to include('t.index [:roleable_id, :roleable_type, :role_id], unique: true')
  end

end
