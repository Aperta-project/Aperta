class ApplicationPolicy
  class ApplicationPolicyError < StandardError; end;
  class ApplicationPolicyNotFound < ApplicationPolicyError; end;

  class_attribute :required_params
  class_attribute :allowed_params

  def self.require_params(*args)
    self.required_params ||= []
    self.required_params += args
    attr_accessor *args
  end

  def self.allow_params(*args)
    self.allowed_params ||= []
    self.allowed_params += args
    attr_accessor *args
  end

  def self.permitted_params
    self.allowed_params.to_a + self.required_params.to_a
  end

  def self.find_policy(controller_class, user, args={})
    policy_class(controller_class).new({current_user: user}.merge(args))
  end

  def self.policy_class(controller_class)
    controller_class.name.gsub(/Controller$/, "Policy").constantize
  end

  require_params :current_user

  def initialize(params={})
    @action_cache = {}
    validate_params(params)
    params.each do |k,v|
      if self.class.permitted_params.include?(k)
        self.send "#{k}=", v
      end
    end
  end

  def applies_to?(controller_class, user, args={})
    self.class == policy_class(controller_class) && current_user == user
  end

  def policy_class(controller_class)
    self.class.policy_class(controller_class)
  end

  def authorized?(action)
    if @action_cache[action].nil?
      @action_cache[action] = query_self(action)
    end
    @action_cache[action]
  end

  def query_self(action)
    action = "#{action}?".to_sym
    if respond_to?(action)
      !!self.send(action)
    else
      raise ApplicationPolicyNotFound, "#{self.class.name} does not define the policy for controller action :#{action}"
    end
  end
  private :query_self

  # restrictive default policy
  #
  def index?
    false
  end

  def new?
    create?
  end

  def create?
    false
  end

  def edit?
    update?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  private

  def super_admin?
    current_user.admin?
  end

  def validate_params(params)
    missing = (self.class.required_params - params.keys)
    if missing.any?
      raise ApplicationPolicyError, "The following required parameters were not sent #{missing}"
    end
  end

  def administered_journals
    current_user.administered_journals
  end

  def can_administer_any_journal?
    super_admin? || administered_journals.any?
  end

  def can_administer_journal?(journal)
    super_admin? || administered_journals.exists?(journal)
  end

end
