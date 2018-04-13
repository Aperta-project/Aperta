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

require_relative 'production'

Tahi::Application.configure do
  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  if ENV["HEROKU_PARENT_APP_NAME"].present?
    # this is only set for review apps. they end up with a domain like
    # "tahi-staging-pr-1786", which we can use to build up the asset host for
    # review apps
    review_app_host = "#{ENV["HEROKU_APP_NAME"]}.herokuapp.com"
    config.action_controller.asset_host = "//#{review_app_host}"
    config.action_mailer.default_url_options = { host: review_app_host }
    routes.default_url_options = { host: review_app_host }
  else
    # use overriden asset host from config
    config.action_controller.asset_host = ENV.fetch("RAILS_ASSET_HOST")
    config.action_mailer.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }

    # Define how root_url should behave by default
    routes.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }
  end
end
