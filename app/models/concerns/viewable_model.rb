# Provides an additional layer of abstraction about the core permissions system
# to check if a user can view this thing. Perhaps at some point this will not be
# necessary, but as long as we have move complicated checks to see if a user can
# view something, this helps to make it clearer.
#
# This should be used by both serializers and controllers.

module ViewableModel
  extend ActiveSupport::Concern

  # Returns true if the user should be able to view this model. Override for
  # more complicated behavior.
  def user_can_view?(user)
    user.can?(:view, self)
  end

  class_methods do
    def delegate_view_permission_to(method)
      define_method "user_can_view?" do |user|
        user.can?(:view, send(method))
      end
    end
  end
end
