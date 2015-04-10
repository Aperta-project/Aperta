module Notifications
  class Handler
    attr_reader :activity

    def initialize(activity:)
      @activity = activity
    end

    def call
      # TODO: send notification payload to all users via pusher
      update_user_inbox
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
