require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: ENV['AWS_SES_SERVER_NAME'],
  #   port: 587,
  #   domain: 'hyperlog.io',
  #   user_name: ENV['AWS_SES_USERNAME'],
  #   password: ENV['AWS_SES_PASSWORD'],
  #   authentication: 'login',
  #   enable_starttls_auto: true
  # }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # GitHub OAuth app used for analysis
  config.x.profiles.github_client_id = ENV['GITHUB_ANALYSIS_CLIENT_ID']
  config.x.profiles.github_client_secret = ENV['GITHUB_ANALYSIS_CLIENT_SECRET']

  # Endpoint for triggering initial analysis
  config.x.profiles.initial_analysis_invocation_url = ENV['INITIAL_ANALYSIS_INVOCATION_URL']

  # Endpoint and authentication for Theme Build
  config.x.profiles.theme_build_invocation_url = ENV['THEME_BUILD_INVOCATION_URL']
  config.x.profiles.theme_build_basic_auth = [ENV['THEME_BUILD_BASIC_USER'], ENV['THEME_BUILD_BASIC_PASS']]

  # Endpoint for SEO image generation
  config.x.profiles.users_seo_image_url = ENV.fetch('USERS_SEO_IMAGE_URL', 'http://localhost:5301/users')

  # Endpoint for triggering repo analysis
  config.x.repos.repo_analysis_invocation_url = ENV['REPO_ANALYSIS_INVOCATION_URL']
end
