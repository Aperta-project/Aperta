require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(:default, Rails.env)

module Tahi
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    config.s3_bucket = :not_set
    config.carrierwave_storage = :file
  end
end
