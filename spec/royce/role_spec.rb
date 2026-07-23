# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Basic tests' do # rubocop:disable RSpec/DescribeClass

  before { User.delete_all }

  let(:user) { User.create }

  it 'can create role' do
    role = Royce::Role.create(name: 'some_role')
    expect(role).to_not be_nil
    expect(role.name).to eq 'some_role'
    expect(role.to_s).to eq 'some_role'
  end

  it 'Can create user' do
    user = User.create
    expect(user).to_not be_nil
  end

  it 'Creates roles automatically' do
    user
    expect(Royce::Role.count).to be > 0
  end

  describe 'adding roles' do
    it 'can add with string' do
      user.add_role 'user'
      expect(user.roles.count).to eq 1
    end

    it 'can add with symbol' do
      user.add_role :user
      expect(user.roles.count).to eq 1
    end

    it 'can add with Role object' do
      User.available_roles.each do |role|
        user.add_role role
      end
      expect(user.roles.count).to eq User.available_roles.count
    end
  end

  describe 'Removing roles' do
    it 'can remove with string' do
      user.add_role 'user'
      user.remove_role 'user'
      expect(user.roles.count).to eq 0
    end

    it 'can remove with symbol' do
      user.add_role :user
      user.remove_role :user
      expect(user.roles.count).to eq 0
    end
  end

  it 'Can query role name' do
    expect(user.has_role?('user')).to be false
    expect(user.has_role?(:user)).to be false
    user_role = Royce::Role.find_by(name: 'user')
    expect(user.has_role?(user_role)).to be false

    user.add_role 'user'

    expect(user.has_role?('user')).to be true
    expect(user.has_role?(:user)).to be true
    expect(user.has_role?(user_role)).to be true
  end

  it 'Can tell acceptable roles' do
    expect(user.allowed_role?('zxcv')).to be false
    expect(user.allowed_role?('user')).to be true
    expect(user.allowed_role?(:zxcv)).to be false
    expect(user.allowed_role?(:user)).to be true

    user_role = Royce::Role.find_or_create_by(name: 'user')
    expect(user.allowed_role?(user_role)).to be true

    bad_role = Royce::Role.find_or_create_by(name: 'zxcv')
    expect(user.allowed_role?(bad_role)).to be false
  end

  it 'Has name methods' do
    User.available_roles.each do |role|
      method_name = "#{role}?"
      expect(user.send(method_name)).to be false
      user.add_role role
      expect(user.send(method_name)).to be true
    end
  end

  it 'Has bang methods to assign a role' do
    expect(user.has_role?(:admin)).to be false
    user.admin!
    expect(user.has_role?(:admin)).to be true

    expect(user.has_role?(:editor)).to be false
    user.editor!
    expect(user.has_role?(:editor)).to be true
  end

  it 'knows allowed roles' do
    User.available_roles.each do |role|
      expect(user.allowed_role?(role)).to be true
    end
  end

  it 'has named scopes for each role' do
    User.available_roles.each do |role|
      expect {
        User.send(role.name.pluralize.to_sym)
      }.to_not raise_error
    end
  end

  it 'has a list of roles' do
    expect(user.role_list).to eq []

    user.add_role :user
    expect(user.role_list).to eq ['user']

    user.add_role :admin
    expect(user.role_list).to eq %w[user admin]
  end

  it 'doesnt get double roles' do
    expect(user.roles.count).to eq 0

    user.admin!
    expect(user.roles.count).to eq 1

    user.admin!
    expect(user.roles.count).to eq 1
  end

  describe 'return values' do
    it 'add_role returns false for a disallowed role and true when applied' do
      expect(user.add_role(:zxcv)).to be false
      expect(user.add_role(:user)).to be true
      expect(user.add_role(:user)).to be true # already assigned, still success
    end

    it 'remove_role returns false for a disallowed role and true otherwise' do
      expect(user.remove_role(:zxcv)).to be false
      expect(user.remove_role(:user)).to be true
    end
  end

  describe 'remove_role with a Role object' do
    it 'removes the role' do
      user.add_role :user
      role = Royce::Role.find_by(name: 'user')
      user.remove_role role
      expect(user.has_role?(:user)).to be false
    end
  end

  describe 'when an allowed role row is missing' do
    it 'recreates it instead of raising' do
      user.add_role :user
      Royce::Role.where(name: 'user').delete_all
      expect(Royce::Role.find_by(name: 'user')).to be_nil

      expect { user.add_role :user }.to_not raise_error
      expect(Royce::Role.find_by(name: 'user')).to_not be_nil
      expect(user.reload.has_role?(:user)).to be true
    end

    it 'remove_role returns true without deleting when the row is absent' do
      Royce::Role.where(name: 'user').delete_all
      expect(Royce::Role.find_by(name: 'user')).to be_nil

      expect(user.remove_role(:user)).to be true
    end
  end

  describe 'concurrent insert of the same connector' do
    it 'add_role swallows RecordNotUnique and reports success' do
      allow(user.roles).to receive(:<<).and_raise(ActiveRecord::RecordNotUnique)

      expect(user.add_role(:user)).to be true
    end
  end
end
