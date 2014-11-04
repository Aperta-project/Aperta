class Accessibility

  attr_accessor :resource, :action

  def initialize(resource, action=:show)
    @resource = resource
    @action = action
  end

  def users
    action.present? ? filtered_users : connected_users
  end


  private

  def filtered_users
    connected_users.select do |user|
      policy(user).send("#{action}?")
    end.uniq
  end

  def policy(user=nil)
    #TODO: instead of hardcoding paper:, it should send necessary policy attributes
    policy_klass.new(current_user: user, paper: resource)
  end

  def connected_users
    policy.connected_users
  end

  def policy_klass
    klass_name = "#{resource.class.name.pluralize}Policy"
    klass_name.constantize
  rescue NameError
    raise ApplicationPolicy::ApplicationPolicyNotFound, "Could not find #{klass_name} for #{resource}"
  end

end
