# Cache management logic for Authorizations::UserHelper#can?
class CanCache
  KEY_PREFIX = "can_user".freeze
  class << self
    def user_cache_key(user)
      "#{KEY_PREFIX}_#{user.id}"
    end

    def cache_bust(user = nil)
      Sidekiq.redis do |redis|
        keys = user ? [user_cache_key(user)] : redis.scan_each(match: "#{KEY_PREFIX}_*").to_a
        redis.del(*keys) unless keys.empty?
      end
    end

    def fetch(user, permission, target)
      target_class = target.try(:id) ? target.class : target
      field = [permission, target_class.to_s.underscore, target.try(:id)].compact.join('_')
      key = user_cache_key(user)
      Sidekiq.redis do |redis|
        unless value = redis.hget(key, field)
          value = yield.to_s
          redis.hset(key, field, value)
        end
        value == 'true' # redis only stores strings
      end
    end
  end
end
