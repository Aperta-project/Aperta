# Controller helper for roles and permissions
# ex: requires_user_can :withdraw, paper
module AuthorizationsControllerHelper
  extend ActiveSupport::Concern

  # Error when user is unauthorized to perform action. Raises HTTP 403.
  class AuthorizationError < StandardError; end

  # Error when user is unauthorized to perform action or action not found. Raises HTTP 404.
  # This error has the advantage of not revealing to the user the existence of certain resources.
  class NotFoundError < StandardError; end

  included do
    rescue_from AuthorizationError, with: :unauthorized
    rescue_from NotFoundError, with: :not_found
  end

  def requires_user_can(permission, object, not_found: false)
    return if current_user.can?(permission, object)
    if not_found
      raise NotFoundError
    else
      raise AuthorizationError
    end
  end

  private

  def unauthorized
    head :forbidden
  end

  def not_found
    render text: "Sorry, we're unable to find the page you requested.", status: 404
  end
end
