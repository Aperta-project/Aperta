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

module TahiPusher
  class Config
    # injected into ember layout (ember.html.erb)
    # then loaded into ember client (pusher-override.coffee)
    def self.as_json(_ = {})
      {
        enabled: true,
        auth_endpoint_path:
          Rails.application.routes.url_helpers.auth_event_stream_path,
        key: Pusher.key,
        channels: [TahiPusher::ChannelName::SYSTEM]
      }.merge(socket_options)
    end

    def self.socket_options
      if defined?(PusherFake)
        PusherFake.configuration.socket_options
      elsif ENV.key?('PUSHER_SOCKET_URL')
        # I believe this works because pusher has a standard host & port to use
        # and does not require setting.
        {}
      else
        {
          host: ENV["EVENT_STREAM_WS_HOST"],
          port: ENV["EVENT_STREAM_WS_PORT"]
        }
      end
    end
  end
end
