class FlashMessageSubscriber
  def self.call(event_name, event_data)
    subscriber = new(event_name, event_data)
    subscriber.run
  end

  def initialize(event_name, event_data)
    @event_name = event_name
    @event_data = event_data
  end

  def run
    mt = message_type
    return if mt.nil?
    TahiPusher::Channel.
      delay(queue: :eventstream, retry: false).
      push(channel_name: "private-user@#{user.id}",
           event_name: 'flashMessage',
           payload: { messageType: mt,
                      message: message })
  end

  def user
    fail NotImplementedError, 'You must define the user that receives the flash message'
  end

  def message
    fail NotImplementedError, 'You must define the flash message that the user receives'
  end

  def message_type
    fail NotImplementedError, 'You must define the type of the flash message that the user receives'
  end
end
