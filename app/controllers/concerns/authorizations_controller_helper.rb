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

  def requires_that(not_found: false)
    return if yield
    raise NotFoundError if not_found
    raise AuthorizationError
  end

  def requires_user_can(permission, object, not_found: false)
    requires_that(not_found: not_found) do
      current_user.can?(permission, object)
    end
  end

  def requires_user_can_view(object, not_found: false)
    requires_that(not_found: not_found) do
      object.user_can_view?(current_user)
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
