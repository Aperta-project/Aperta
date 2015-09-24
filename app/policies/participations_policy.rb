class ParticipationsPolicy < ApplicationPolicy
  primary_resource :participation
  allow_params :for_task

  include TaskAccessCriteria

  def index?
    authorized_to_modify_task?
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
    for_task || participation.task
  end

  def tasks_policy
    @tasks_policy ||= TasksPolicy.new(current_user: current_user, resource: task)
  end
end
