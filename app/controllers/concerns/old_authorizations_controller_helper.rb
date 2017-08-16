module OldAuthorizationsControllerHelper
  extend ActiveSupport::Concern

  class AuthorizationError < StandardError; end

  included do
    rescue_from AuthorizationError, with: :render_forbidden
  end

  def enforce_policy
    authorize_action!
  end

  def authorize_action!(args = {})
    policy = find_policy(self.class, current_user, args)
    raise AuthorizationError unless policy.authorized?(action_name)
  end

  def render_forbidden
    if request.xhr? || (request.format != :html)
      head :forbidden
    else
      redirect_to root_path
    end
  end

  def find_policy(controller_class, user, args)
    @policies ||= []
    policy = nil

    if @policies.present?
      policy = @policies.detect { |p| p.applies_to?(controller_class, user, args) }
    end

    unless policy
      policy = ApplicationPolicy.find_policy(controller_class, user, args)
      @policies << policy
    end

    policy
  end
end
