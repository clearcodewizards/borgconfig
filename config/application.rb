require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BorgCollective
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks directives borg_cube])

    # Secrets are supplied directly by the environment; this application does
    # not depend on Rails encrypted credentials. Local environments retain
    # public defaults, while production fails fast when a value is missing.
    config.credentials.content_path = root.join("config/credentials.yml.enc.disabled")
    config.credentials.key_path = root.join("config/master.key.disabled")

    env_secret = lambda do |name, local_default|
      if Rails.env.local? || ENV["SECRET_KEY_BASE_DUMMY"]
        ENV.fetch(name, local_default)
      else
        ENV.fetch(name)
      end
    end

    config.secret_key_base = env_secret.call("SECRET_KEY_BASE", "borg-collective-local-secret-key-base")
    config.active_record.encryption.primary_key =
      env_secret.call("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "borg-collective-local-primary-key")
    config.active_record.encryption.deterministic_key =
      env_secret.call("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "borg-collective-local-deterministic-key")
    config.active_record.encryption.key_derivation_salt =
      env_secret.call("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT", "borg-collective-local-key-derivation-salt")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
