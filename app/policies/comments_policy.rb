class CommentsPolicy < ApplicationPolicy
  primary_resource :comment
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

  private

  def task
    for_task || comment.task
  end

  def tasks_policy
    @tasks_policy ||= TasksPolicy.new(current_user: current_user, resource: task)
  end
end
