## [Unreleased]

## [0.0.5] - 2025-04-11
* Removed an unnecessary comment from the spec/spec_helper.rb file.
* Enforced the use of frozen string literals in several Ruby files.
* Standardized the use of double quotes for string literals across various files.
* Refactored the PasswordsController to reside under the Api::V1 namespace.
* Refactored the SessionsController to reside under the Api::V1 namespace.
* Refactored the UsersController to reside under the Api::V1 namespace.

## [0.0.4] - 2025-04-11
* Added activerecord gem as a runtime dependency for Rails 8 compatibility.
* Introduced the initial user model specification with tests for validations.
* Included a basic structure for association and role-based authorization tests (role tests are pending implementation).
* Updated the main gem specification file to use the correct `CrumbKit` module name.
* Removed the placeholder test from the main gem specification.
* Added frozen string literal comments to relevant files.

## [0.0.3] - 2025-04-11
* Fixed issue with loading the version file in the gemspec.
* Corrected the homepage URL in the gemspec.
* Updated the description and summary in the gemspec.
* Added rspec and rspec-rails as development dependencies.

## [0.0.2] - 2025-04-11

* Initial release of the crumb-kit gem.
* Implemented user model with password authentication.
* Added session management with JWT.
* Included password reset functionality.

## [0.0.1] - 2025-04-11

* Initial commit of the gem structure.