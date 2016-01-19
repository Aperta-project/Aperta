module TahiPusher::CurrentUserTracker
  extend ActiveSupport::Concern

  included do
    def set_current_user_id
      RequestStore.store[:requester_current_user_id] = current_user.try(:id)
    end
  end
end
