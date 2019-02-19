ActiveRecord::Schema.define do
  self.verbose = false

  create_table :royce_connector, force: true do |t|
    t.integer  :roleable_id,   null: false
    t.string   :roleable_type, null: false
    t.integer  :role_id,       null: false
    t.datetime :created_at
    t.datetime :updated_at

    t.index [:role_id]
    t.index [:roleable_id, :roleable_type]
  end


  create_table :royce_role, force: true do |t|
    t.string   :name,       null: false
    t.datetime :created_at
    t.datetime :updated_at

    t.index :name
  end

  create_table :users, force: true do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :employees, force: true do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :baby_boomers, force: true do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end
end
