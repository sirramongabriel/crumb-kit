# frozen_string_literal: true

require 'bcrypt'

require 'rails'
require 'rails/railtie'
require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'bundler/setup'

# Define a minimal Rails engine for testing
class CrumbKitTestApp < Rails::Engine
  config.root = File.expand_path('dummy', __dir__)
  engine_root = File.expand_path('../../', __dir__)
  # These lines configure the paths for the engine/dummy app to find your models, etc.
  config.eager_load_paths << File.join(engine_root, 'app', 'models')
  config.autoload_paths << File.join(engine_root, 'app', 'models')
  # Add other relevant app paths if you have controllers, services, etc. in app/
  config.eager_load_paths << File.join(engine_root, 'app', 'controllers')
  config.autoload_paths << File.join(engine_root, 'app', 'controllers')
  config.eager_load_paths << File.join(engine_root, 'app', 'services')
  config.autoload_paths << File.join(engine_root, 'app', 'services')

  config.eager_load = false # Typically false for testing, relying on autoloading
  config.middleware.use ActionDispatch::Cookies
  config.middleware.use ActionDispatch::Session::CookieStore, key: '_crumb_kit_session'
end

# Boot the dummy Rails app environment.
# This activates the engine's configured eager_load_paths and autoload_paths,
# making files in app/models, app/controllers, etc. available via autoloading.
begin
  require File.expand_path('dummy/config/environment', __dir__)
rescue LoadError
  puts 'Could not load dummy application environment. Make sure spec/dummy is a valid Rails app.'
  exit 1
end

# --- ADDED BACK: Explicitly require models from the gem's app/models directory. ---
# Autoloading might not be triggered early enough during spec file loading.
begin
  require_relative '../app/models/crumb_kit/user'
  require_relative '../app/models/crumb_kit/session'
  require_relative '../app/models/crumb_kit/current' # Assuming CrumbKit::Current is defined here
rescue LoadError => e
  puts "Error explicitly requiring gem models: #{e.message}"
  puts e.backtrace.first(5) # Print a few lines of the backtrace
  exit 1 # Exit if essential models can't be loaded
end
# --- END ADDED BACK ---

require 'crumb_kit'

require 'active_record'
require 'shoulda/matchers'
require 'database_cleaner'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: ENV['TEST_DATABASE'] || 'crumb_kit_test',
  username: ENV['TEST_USERNAME'],
  password: ENV['TEST_PASSWORD'],
  host: ENV['TEST_HOST'] || 'localhost',
  port: ENV['TEST_PORT'] || 5432
)

# Define the database schema for tests
# This block will run once when spec_helper is loaded.
# DatabaseCleaner will handle cleaning data within this schema.

unless ActiveRecord::Base.connection.table_exists?('users')
  ActiveRecord::Schema.define do # rubocop:disable Metrics/BlockLength
    drop_table :sessions if ActiveRecord::Base.connection.table_exists?('sessions')
    drop_table :users if ActiveRecord::Base.connection.table_exists?('users')

    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :name_slug
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ['email'], name: 'index_users_on_email', unique: true
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
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

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

  # Database Cleaner configuration (assuming you use it for data cleaning between tests)
  # Make sure 'database_cleaner' gem is in your Gemfile (likely under development group)
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    # If you need to clean the schema itself before the suite (e.g., if not using Schema.define every time)
    # DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
