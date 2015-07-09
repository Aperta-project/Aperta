class EventStreamPolicy < ApplicationPolicy
  require_params :resource

  def show?
    policy.show?
  end

  private

  def policy
    policy_klass.new(current_user: current_user, resource: resource)
  end

  def policy_klass
    klass_name = "#{resource.class.name.pluralize}Policy"
    klass_name.constantize
  rescue NameError
    raise ApplicationPolicy::ApplicationPolicyNotFound, "Could not find #{klass_name} for #{resource}"
  end

end
