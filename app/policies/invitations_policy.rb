class InvitationsPolicy < ApplicationPolicy
  primary_resource :invitation

  def connected_users
    tasks_policy.connected_users
  end

  def show?
    tasks_policy.show?
  end

  private

  def tasks_policy
    @tasks_policy ||= TasksPolicy.new(current_user: current_user, resource: invitation.task)
  end
end
