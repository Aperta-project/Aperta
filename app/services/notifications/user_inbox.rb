module Notifications
  class UserInbox
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def set(*values)
      redis.sadd(key, values)
    end

    def get
      redis.smembers(key)
    end

    def remove(*values)
      redis.srem(key, values)
    end

    private

    def key
      "user::#{user_id}::inbox"
    end

    def redis
      @redis ||= Redis.new
    end
  end
end
