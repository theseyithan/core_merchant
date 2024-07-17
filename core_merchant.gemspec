# frozen_string_literal: true

require_relative "lib/core_merchant/version"

Gem::Specification.new do |spec|
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

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
