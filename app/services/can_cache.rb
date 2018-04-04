# Cache management logic for Authorizations::UserHelper#can?
class CanCache
  KEY_PREFIX = "can_user".freeze
  class << self
    def cache_key(user, permission, target)
      target_class = target.try(:id) ? target.class : target
      [KEY_PREFIX, user.id, permission, target_class.to_s.underscore, target.try(:id)].compact.join('_')
    end

    def user_cache_bust(user)
      Rails.cache.delete_matched(/^#{KEY_PREFIX}_#{user.id}/)
    end

    def permissions_cache_bust(permissions)
      regex_fragments = permissions.map { |perm| "#{perm.action}_#{perm.applies_to.underscore}" }
      Rails.cache.delete_matched(/^#{KEY_PREFIX}.*(#{regex_fragments.join('|')})/)
    end

    def paper_state_cache_bust
      stateful_permissions = Permission.includes(:states).where.not(permission_states: { name: '*' })
      permissions_cache_bust(stateful_permissions)
    end
  end
end
