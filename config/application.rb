# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

require File.dirname(__FILE__) + '/../lib/tahi_env'
TahiEnv.validate!

module Tahi
  class Application < Rails::Application
    config.s3_bucket = ENV.fetch('S3_BUCKET', :not_set)
    config.carrierwave_storage = :fog
    config.x.admin_email = TahiEnv.admin_email
    config.from_email = ENV.fetch('FROM_EMAIL', 'no-reply@example.com')

    # Raise an error within after_rollback & after_commit
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sidekiq

    if TahiEnv.basic_auth_required?
      config.basic_auth_user = TahiEnv.basic_http_username
      config.basic_auth_password = TahiEnv.basic_http_password
    end

    config.x.pusher_verbose_logging = TahiEnv.pusher_verbose_logging?

    config.omniauth_providers = []
  end
end
