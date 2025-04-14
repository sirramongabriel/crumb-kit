# frozen_string_literal: true

# CrumbKit::Engine integrates CrumbKit gem into a Rails application.
# It allows the host app to customize configurations such as the session model.
#
# Example of configuring CrumbKit in the host application:
#   # config/initializers/crumb_kit.rb
#   CrumbKit::Engine.config.session_model = 'CustomSession'
class CrumbKit::Engine < ::Rails::Engine
  # Initializer to configure CrumbKit with default values or overrides from the host app.
  initializer 'crumb_kit.configure' do |app|
    # Create a configuration object for the CrumbKit engine
    app.config.crumb_kit = ActiveSupport::OrderedOptions.new

    # Default session model configuration, can be customized by the host app
    app.config.crumb_kit.session_model = 'CrumbKit::Session' # Default session model

    # Example of allowing customization for a host app's session model
    # app.config.crumb_kit.session_model = 'CustomSession'
  end
end
