class InvitationsPolicy < ApplicationPolicy
  primary_resource :invitation

  def connected_users
    user_ids = (tasks_policy.connected_users.pluck(:id) + [invitation.invitee.id])
    User.where(id: user_ids)
  end

  def show?
    invitation.invitee == current_user || tasks_policy.show?
  end

  private

  def tasks_policy
    @tasks_policy ||= TasksPolicy.new(current_user: current_user, resource: invitation.task)
  end
end
