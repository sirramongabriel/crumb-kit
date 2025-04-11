# frozen_string_literal: true

require "crumb_kit"
require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do # rubocop:disable Metrics/BlockLength
  create_table :users do |t|
    t.string :first_name, null: false
    t.string :last_name, null: false
    t.string :username, null: false
    t.string :name_slug
    t.string :email, null: false
    t.string :password_digest, null: false
    t.string :password_reset_token
    t.datetime :password_reset_sent_at
    t.string :profile_picture
    t.integer :rating
    t.datetime :created_at, null: false
    t.datetime :updated_at, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table :sessions do |t|
    t.datetime :expires_at
    t.string :ip_address
    t.string :user_agent
    t.string :token
    t.string :refresh_token
    t.bigint :user_id
    t.boolean :remember_me, default: false
    t.datetime :revoked_at
    t.string :location
    t.string :device_id
    t.datetime :extended_at
    t.datetime :last_accessed_at
    t.datetime :created_at, null: false
    t.datetime :updated_at, null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  # Add other table definitions as needed (e.g., addresses, roles, user_roles)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  Shoulda::Matchers.configure do |shoulda_config|
    shoulda_config.integrate do |with|
      with.test_framework :rspec
      with.library :active_model
      with.library :active_record
    end
  end
end
