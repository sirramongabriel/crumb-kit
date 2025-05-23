# frozen_string_literal: true

require_relative 'lib/crumb_kit/version'

Gem::Specification.new do |spec|
  spec.name = 'crumb-kit'
  spec.version = CrumbKit::VERSION
  spec.authors = ['sirramongabriel']
  spec.email = ['sirramongabriel@gmail.com']

  spec.summary = 'Authentication for Rails API using JWT and sessions.'
  spec.description = 'Provides authentication functionality for Rails API applications using JWT and sessions.'
  spec.homepage = 'https://github.com/sirramongabriel/crumb-kit'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/sirramongabriel/crumb-kit'
  spec.metadata['changelog_uri'] = 'https://github.com/sirramongabriel/crumb-kit/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'activerecord', '~> 8.0'
  spec.add_dependency 'bcrypt', '~> 3.1'
  spec.add_dependency 'rails', '>= 7.0'
  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'rake', '~> 13.0'

  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'shoulda-matchers', '~> 5.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
