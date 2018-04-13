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

if TahiEnv.redis_sentinel_enabled?
  Sidekiq.redis = {
    url: ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL'],
    role: :master,
    # This option is actually the master name, not a host
    host: 'aperta',
    sentinels: TahiEnv.redis_sentinels.map do |s|
      u = URI.parse(s)
      { host: u.host, port: (u.port || 26_379) }
    end,
    failover_reconnect_timeout: 20,
    namespace: "tahi_#{Rails.env}"
  }
else
  redis_options = { namespace: "tahi_#{Rails.env}" }
  # Use fakeredis in the test environment
  redis_options[:driver] = Redis::Connection::Memory if Rails.env.test?
  Sidekiq.redis = redis_options
end

Sidekiq.configure_server do |config|
  ActiveSupport.on_load(:active_record) do
    ar_config = ActiveRecord::Base.configurations[Rails.env]
    ar_config['pool'] = config.options[:concurrency]
    ActiveRecord::Base.establish_connection(ar_config)
  end
end
