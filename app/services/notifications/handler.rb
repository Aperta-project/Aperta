module Notifications
  class Handler
    attr_reader :activity

    def initialize(activity:)
      @activity = activity
    end

    def call
      broadcast_messages
      update_user_inbox
    end

    def broadcast_messages
      users.each do |user|
        Stream.new(user: user, activity: activity).post
      end
    end

    def update_user_inbox
      users.each do |user|
        UserInbox.new(user.id).set(activity.id)
      end
    end

    private

    def users
      @users ||= Accessibility.new(activity.target).users
    end
  end
end
