# Controller helper for roles and permissions
# ex: requires_user_can :withdraw_manuscript, paper
module AuthorizationsControllerHelper
  extend ActiveSupport::Concern

  # Error when user is unauthorized to perform action. Raises HTTP 403.
  class AuthorizationError < StandardError; end

  included do
    rescue_from AuthorizationError, with: :unauthorized
  end

  def requires_user_can(permission, object)
    return if current_user.can?(permission, object)
    fail AuthorizationError
  end

  private

  def unauthorized
    head :forbidden
  end
end
