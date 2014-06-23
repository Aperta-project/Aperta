module Authorizations
  extend ActiveSupport::Concern

  class AuthorizationError < StandardError; end;

  included do
    rescue_from AuthorizationError, with: :render_forbidden
    helper_method :can_perform?
    helper_method :can_perform_action?
  end

  def enforce_policy
    authorize_action!
  end

  def authorize_action!(args={})
    policy = find_policy(self.class, current_user, args)
    unless policy.authorized?(action_name)
      raise AuthorizationError
    end
  end

  def render_forbidden
    if !request.xhr?
      redirect_to root_path
    else
      head :forbidden
    end
  end

  def find_policy(controller_class, user, args)
    @policies ||= []
    policy = nil

    if @policies.present?
      policy = @policies.detect { |p| p.applies_to?(controller_class, user, args) }
    end

    if !policy
      policy = ApplicationPolicy.find_policy(controller_class, user, args)
      @policies << policy
    end

    policy
  end
end
