# frozen_string_literal: true

require_relative "lib/core_merchant/version"

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name = "core_merchant"
  spec.version = CoreMerchant::VERSION
  spec.authors = ["Seyithan Teymur"]
  spec.email = ["seyithan@me.com"]
  spec.summary = "A library for merchant, product, and subscription management in Rails applications."
  spec.description = <<~DESCRIPTION
    CoreMerchant provides essential functionality for handling customers, products, and subscriptions in e-commerce and SaaS applications. Does not include payment integrations.
  DESCRIPTION
  spec.homepage = "https://github.com/theseyithan/core_merchant"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Remove this line if you plan to push to any rubygems server
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 7.0"
  spec.add_dependency "rails", "~> 7.0"

  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "generator_spec", "~> 0.9.4"
  spec.add_development_dependency "railties", "~> 7.0"
  spec.add_development_dependency "rspec-rails", "~> 5.0"
  spec.add_development_dependency "sqlite3", "~> 1.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
