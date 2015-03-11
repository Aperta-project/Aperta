module Notifications
  class Stream
    attr_reader :activity, :actor, :target, :event, :user

    def initialize(activity:, actor:, target:, event:, user:)
      @activity = activity
      @actor = actor
      @target = target
      @event = event
      @user = user
    end

    def post
      channel = EventStreamConnection.channel_name(User, user.id)
      EventStreamConnection.post_event(channel, payload.to_json)
    end

    private

    def payload
      model_name = target.class.name.demodulize.underscore
      {
        id: activity.id,
        actor: { user: actor.id },
        event: event,
        target: { model_name.to_sym => target.id }
      }
    end
  end
end
