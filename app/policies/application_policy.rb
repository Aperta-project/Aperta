class ApplicationPolicy
  class ApplicationPolicyError < StandardError; end;
  class ApplicationPolicyNotFound < ApplicationPolicyError; end;

  class_attribute :required_params
  class_attribute :allowed_params
  class_attribute :primary_resource_name

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

  def self.primary_resource(resource_name)
    self.primary_resource_name = resource_name
    attr_accessor resource_name
    alias_method :resource, resource_name
    alias_method :resource=, "#{resource_name}="
  end

  def self.permitted_params
    allowed_params.to_a + required_params.to_a + [primary_resource_name, :resource]
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

  def update?
    false
  end

  def destroy?
    false
  end

  private

  def super_admin?
    current_user.site_admin?
  end

  def validate_params(params)
    validate_resource(params) if self.class.primary_resource_name
    missing = (self.class.required_params - params.keys)
    if missing.any?
      raise ApplicationPolicyError, "The following required parameters were not sent #{missing}"
    end
  end

  def validate_resource(params)
    unless self.class.primary_resource_name.in?(params.keys) || :resource.in?(params.keys)
      raise ApplicationPolicyError, "Please specify either :resource or :#{self.class.primary_resource_name}."
    end
  end

  def administered_journals
    current_user.administered_journals
  end

  def can_administer_any_journal?
    super_admin? || administered_journals.any?
  end

  def can_view_flow_manager?
    can_administer_any_journal? || current_user.can_view_flow_manager?
  end

  def can_administer_journal?(journal)
    super_admin? || administered_journals.include?(journal)
  end

  def author_of_paper?(paper)
    current_user.created_papers.where(id: paper.id).present?
  end

  def can_view_paper?(paper)
    (current_user.site_admin? ||
      current_user.can?(:view, paper) ||
      paper.assigned_users.where(id: current_user.id).exists? ||
      can_view_manuscript_manager?(paper))
  end

  def can_view_manuscript_manager?(paper)
    (current_user.site_admin? ||
     current_user.old_roles.where(journal_id: paper.journal).
       where("can_view_assigned_manuscript_managers = ? OR can_view_all_manuscript_managers = ?", true, true).
       exists?)
  end
end
