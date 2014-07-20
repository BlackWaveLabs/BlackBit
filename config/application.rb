require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Ruby-wallet
require "coind"

Bundler.require(*Rails.groups)

module Blackbit
  class Application < Rails::Application
    config.i18n.default_locale = :en
  end
end
