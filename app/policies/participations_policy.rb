class ParticipationsPolicy < ApplicationPolicy
  primary_resource :participation

  include TaskAccessCriteria

  def connected_users
    tasks_policy.connected_users
  end

  def show?
    authorized_to_modify_task?
  end

  def create?
    authorized_to_modify_task?
  end

  def destroy?
    authorized_to_modify_task?
  end

  private

  def task
    participation.task
  end

  def tasks_policy
    @tasks_policy ||= TasksPolicy.new(current_user: current_user, resource: task)
  end
end
