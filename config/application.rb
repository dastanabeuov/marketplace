require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Marketplace
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.time_zone = "Almaty"
    config.i18n.fallbacks = true
    config.i18n.default_locale = :ru
    config.i18n.available_locales = %i[ru kz en]

    config.autoload_lib(ignore: %w[assets tasks])

    config.generators do |g|
      g.helper      false
      g.javascripts false
      g.stylesheets false
      g.decorator   false

      g.template_engine :erb
      g.fixture_replacement :factory_bot, dir: "spec/factories"

      g.test_framework :rspec,
        fixtures: true,
        model_specs: true,
        controller_specs: true,

        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        request_specs: false
    end
  end
end
