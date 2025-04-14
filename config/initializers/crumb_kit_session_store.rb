# config/initializers/crumb_kit_session_store.rb
# frozen_string_literal: true

CrumbKit::Engine.config.session_store :cookie_store, key: '_crumb_kit_session', expire_after: 1.hour
