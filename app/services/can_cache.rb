# Cache management logic for Authorizations::UserHelper#can?
class CanCache
  KEY_PREFIX = "can_user".freeze
  class << self
    def cache_key(user, permission, target)
      target_class = target.try(:id) ? target.class : target
      [KEY_PREFIX, user.id, permission, target_class.to_s.underscore, target.try(:id)].compact.join('_')
    end

    def cache_bust(user = nil)
      Rails.cache.delete_matched(/^#{KEY_PREFIX}_#{user.try(:id)}/)
    end
  end
end
