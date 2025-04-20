Sure! Here's your CrumbKit documentation, fully formatted in **Markdown** with proper header tags:

```markdown
# CrumbKit

Authentication for Rails API using JWT and sessions.

CrumbKit is a Ruby gem designed as a Rails Engine to provide a comprehensive solution for handling authentication in Rails API applications. It leverages JSON Web Tokens (JWT) for stateless API authentication and integrates with traditional session management using refresh tokens stored in cookies. It offers built-in models, services, and example controllers to accelerate your API authentication setup.

## Installation

Install the gem by adding this line to your application's Gemfile:

```ruby
gem 'crumb-kit'
```

And then execute:

```bash
bundle install
```

After installing the gem, you will need to set up the necessary database tables for the User and Session models. Refer to the gem's documentation or potential generators for instructions on creating migrations that match the schema required by `CrumbKit::User` and `CrumbKit::Session`.

## Usage

CrumbKit is structured as a Rails Engine and provides several components to integrate into your application.

### Core Concepts

- **CrumbKit::User**: An `ActiveRecord` model providing foundational user attributes and behaviors like password hashing (`has_secure_password`), email normalization, and password reset token management. Your application's user model should extend or include functionality from this base.
- **CrumbKit::Session**: An `ActiveRecord` model that stores active user sessions. It manages the generation and storage of JWT and refresh tokens, along with session expiration. Each session belongs to a user.
- **JwtService**: A service class responsible for the secure encoding and decoding of JWT tokens, including payload encryption.
- **SessionService**: A service class used in authentication workflows (like login and registration) to create session records in the database and handle the setting of JWT and refresh tokens in HTTP cookies.
- **API Controllers**: CrumbKit provides example API controllers (for users, sessions, and passwords) that demonstrate how to implement endpoints for user registration, login, logout, token refresh, and password reset using the gem's models and services. You can use these directly or as a blueprint for your own controllers.
- **Authentication Concern**: A module designed to be included in your application controllers to provide helper methods for authenticating requests and accessing the current user (e.g., `current_user`).

## Setting Up Your Models

Your application should have a User model and a Session model that utilize CrumbKit's components.

```ruby
# app/models/user.rb
class User < CrumbKit::User
  # Add your application specific validations, associations, and methods here
  # Ensure your database table includes columns required by CrumbKit::User
end
```

```ruby
# app/models/session.rb
class Session < CrumbKit::Session
  # Add any application specific session logic here
  # Ensure your database table includes columns required by CrumbKit::Session
end
```

Ensure your database migrations create the necessary tables and columns, such as `email` and `password_digest` for users, and `user_id`, `token`, `refresh_token`, and `expires_at` for sessions.

## Integrating Controllers and Authentication

You can use the controllers provided by CrumbKit by mounting the engine's routes in your `config/routes.rb`:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ... other routes
  mount CrumbKit::Engine, at: '/api/v1' # Example mount path
end
```

Alternatively, you can use the provided controllers as examples to build your own, including the authentication concern in controllers that require authenticated access:

```ruby
# app/controllers/application_controller.rb (or a base API controller)
class ApplicationController < ActionController::API # Or ActionController::Base
  include CrumbKit::Concerns::Authentication # Assuming the concern is named this

  # Use authenticate_request! in controllers or actions that require login
  # before_action :authenticate_request!, except: [:create]
end
```

Provide more specific examples here, such as a basic login controller action or how to use the services directly.

## Configuration

CrumbKit allows for basic configuration via an initializer in your Rails application.

Create `config/initializers/crumb_kit.rb`:

```ruby
# config/initializers/crumb_kit.rb

# Configure CrumbKit engine options
CrumbKit::Engine.config.tap do |config|
  # Configure the session model if it's named differently than CrumbKit::Session
  # config.session_model = 'YourCustomSessionModel'

  # Add other configuration options here as they become available
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run:

```bash
bundle exec rake install
```

To release a new version:

1. Update the version number in `version.rb`
2. Run:

```bash
bundle exec rake release
```

This will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/sirramongabriel/crumb-kit](https://github.com/sirramongabriel/crumb-kit). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct, version 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).  
By participating, you are expected to uphold this code.  
Please report unacceptable behavior to [email-coming-soon].

```
