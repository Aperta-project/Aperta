module Notifications
  class Stream
    attr_reader :activity, :user

    def initialize(activity:, user:)
      @activity = activity
      @user = user
    end

    def post
      channel = EventStreamConnection.channel_name(User, user.id)
      EventStreamConnection.post_event(channel, payload)
    end

    private

    def payload
      Notifications::ActivitySerializer.new(activity).to_json
    end
  end
end
