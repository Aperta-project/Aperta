class Accessibility
  attr_accessor :resource, :action

  def initialize(resource, action=:show)
    @resource = resource
    @action = action
  end

  def users
    action.present? ? filtered_users : connected_users
  end

  def connected?(user)
    users.include?(user)
  end

  def disconnected?(user)
    users.exclude?(user)
  end

  private

  def filtered_users
    connected_users.select do |user|
      policy(user).send("#{action}?")
    end
  end

  def policy(user=nil)
    policy_klass.new(current_user: user, resource: resource)
  end

  def connected_users
    policy.connected_users.uniq.to_a.compact
  end

  def policy_klass
    klass_name = "#{resource.class.name.pluralize}Policy"
    klass_name.constantize
  rescue NameError
    raise ApplicationPolicy::ApplicationPolicyNotFound, "Could not find #{klass_name} for #{resource}"
  end
end
