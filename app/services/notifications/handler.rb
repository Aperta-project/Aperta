module Notifications
  class Handler
    attr_reader :activity, :actor, :target, :event

    def initialize(activity:, actor:, target:, event:)
      @activity = activity
      @actor = actor
      @target = target
      @event = event
    end

    def call
      broadcast_messages
      update_user_inbox
    end

    def update_user_inbox
      users.each do |user|
        UserInbox.new(user.id).set(activity.id)
      end
    end

    def broadcast_messages
      Stream.new(activity: activity, actor: actor, target: target, event: event, users: users).post
    end


    private

    def users
      @users ||= Accessibility.new(target).users
    end
  end
end
