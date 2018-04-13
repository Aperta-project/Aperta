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

# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'emberize'

class EventStreamSubscriber

  attr_reader :action, :record, :excluded_socket_id

  def self.call(event_name, event_data)
    subscriber = new(event_name, event_data)
    subscriber.run
  end

  def initialize(_event_name, event_data)
    @action = event_data[:action]
    @record = event_data[:record]
    @excluded_socket_id = event_data[:requester_socket_id]
  end

  def run
    TahiPusher::Channel.delay(queue: :eventstream, retry: false).
      push(channel_name: channel,
           event_name: action,
           payload: payload,
           excluded_socket_id: excluded_socket_id)
  end

  def payload
    payload_for_record(record)
  end

  def channel
    raise NotImplementedError.new("You must define the channel name for pusher")
  end

  private

  def payload_for_record(record)
    {
      type: Emberize.class_name(record.class),
      id: record.id
    }
  end

  def private_channel_for(model)
    TahiPusher::ChannelName.build(target: model, access: TahiPusher::ChannelName::PRIVATE)
  end

  def system_channel
    TahiPusher::ChannelName.build(target: TahiPusher::ChannelName::SYSTEM, access: TahiPusher::ChannelName::PUBLIC)
  end

  def admin_channel
    TahiPusher::ChannelName.build(
      target: TahiPusher::ChannelName::ADMIN,
      access: TahiPusher::ChannelName::PRIVATE
    )
  end
end
