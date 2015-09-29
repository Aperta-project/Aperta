module EventStreamMatchers

  RSpec::Matchers.define :receive_push do |expected|
    # the payload should contain this key at the root of the json object
    payload = expected[:serialize]
    # the payload will be sent _down_ this channel
    channel = expected[:down]
    # the crud action that corresponds to the event (used by Ember)
    action = expected[:on]

    match do |actual|
      pusher_channel = actual
      expect(pusher_channel).to receive(:push) do |args|
        expect(args[:channel_name]).to match(channel_name(channel))
        expect(args[:event_name]).to eq(action)
        expect(args[:payload][:id]).to be(payload.id)
      end
    end

    def channel_name(channel_scope)
      if channel_scope == 'system'
        /^system$/
      else
        /^private-#{channel_scope}@.*/
      end
    end
  end

end
