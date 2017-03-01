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
    payload_for_record record
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
