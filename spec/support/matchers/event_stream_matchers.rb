module EventStreamMatchers
  RSpec::Matchers.define :receive_push do |expected|
    # the payload should contain this key at the root of the json object
    object = expected[:serialize]

    # the payload will be sent _down_ this channel
    channel = expected[:down]
    # the crud action that corresponds to the event (used by Ember)
    action = expected[:on]

    match do |actual|
      expect(actual).to receive(:push) do |args|
        expect(args[:channel_name]).to match(channel_name(channel))
        expect(args[:event_name]).to eq(action)

        if object
          expect(args[:payload][:id]).to be(object.id)
        else
          expect(args[:payload]).to match(expected[:payload])
        end
      end
    end

    # Not sure if this is what we actually expece, but at least it generally works
    match_when_negated do |actual|
      expect(actual).to_not receive(:push)
      true
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
