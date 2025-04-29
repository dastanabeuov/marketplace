source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.1.0"
# precompile scss sass sintaxis [https://github.com/rails/dartsass-rails]
gem "dartsass-rails", "~> 0.5.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "~> 2.1.0"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0.13"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.3.4"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", "~> 2.13.0"

# Bigdecimal set [https://github.com/ruby/bigdecimal]
gem "bigdecimal", "~> 3.1", ">= 3.1.9"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache", "~> 1.0.7"
gem "solid_queue", "~> 1.1.5"
gem "solid_cable", "3.0.7"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18.4", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", "~> 2.5.3", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "~> 0.1.13", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Decorate object from views [https://github.com/drapergem/draper]
gem "draper", "~> 4.0.4"

# Bootstrap custom style [https://github.com/twbs/bootstrap-rubygem/blob/main/assets/stylesheets/_bootstrap.scss]
gem "bootstrap", "~> 5.3.5"
gem "popper_js"

# Search indexis ibject from find object to form [https://github.com/pat/thinking-sphinx]
gem "mysql2",          "~> 0.4",    platform: :ruby
gem "jdbc-mysql",      "~> 5.1.35", platform: :jruby
gem "thinking-sphinx", "~> 5.5"

# Cron jobs in Ruby [https://github.com/javan/whenever]
gem "whenever", "~> 1.0.0", require: false

# Inernationalization locale [https://github.com/svenfuchs/rails-i18n]
gem "rails-i18n", "~> 8.0.0"

# Authenticate build [https://github.com/heartcombo/devise]
gem "devise-i18n", "~> 1.12"
gem "devise", "~> 4.9"

# Authorize user to resource [https://github.com/CanCanCommunity/cancancan]
gem "cancancan", "~> 3.6"

# Security data table migration structure [https://github.com/ankane/strong_migrations]
gem "strong_migrations", "1.0.0"

# Strong veribles from secret key [https://github.com/bkeepers/dotenv]
gem "dotenv-rails", "~> 3.1.4"

# Breadcrimbs genrated [https://github.com/weppos/breadcrumbs_on_rails]
gem "breadcrumbs_on_rails", "~> 4.1.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw mswin x64_mingw ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "~> 7.0.2", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", "~> 1.1.0", require: false

  # Advanced test [https://github.com/rspec/rspec-rails]
  gem "rspec-rails", "~> 7.1.1"

  # Fabrica bot [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails", "~> 6.4"

  # Open and imulate email send [https://github.com/ryanb/letter_opener]
  gem "letter_opener", "~> 1.10"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.2.1"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.40.0"
  # Use short dsl from test [https://github.com/thoughtbot/shoulda-matchers]
  gem "shoulda-matchers", "~> 6.5"
  gem "rails-controller-testing", "~> 1.0.5"

  # Show how many covvere test app [https://github.com/simplecov-ruby/simplecov]
  gem "simplecov", "~> 0.22.0", require: false

  # Ceaned test db [https://github.com/DatabaseCleaner/database_cleaner-active_record]
  gem "database_cleaner-active_record", "~> 2.2.0"

  # Broser automation framework and ecosystem [https://github.com/SeleniumHQ/selenium/tree/trunk/rb]
  gem "selenium-webdriver", "~> 4.31.0"

  # Save and open page from test [https://github.com/copiousfreetime/launchy]
  gem "launchy", "~> 3.1"
end
