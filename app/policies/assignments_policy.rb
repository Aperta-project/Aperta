class AssignmentsPolicy < ApplicationPolicy
  extend Forwardable

  require_params :paper

  def_delegator :manuscript_managers_policy, :can_manage_manuscript?

  alias_method :index?, :can_manage_manuscript?
  alias_method :create?, :can_manage_manuscript?
  alias_method :destroy?, :can_manage_manuscript?

  private

  def manuscript_managers_policy
    @manuscript_managers_policy ||= ManuscriptManagersPolicy.new(current_user: current_user, paper: paper)
  end
end
