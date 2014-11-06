class CommentsPolicy < ApplicationPolicy
  primary_resource :comment

  include TaskAccessCriteria

  def connected_users
    TasksPolicy.new(current_user: current_user, resource: task).connected_users
  end

  def show?
    authorized_to_modify_task?
  end

  def create?
    authorized_to_modify_task?
  end

  private

  def task
    comment.task
  end
end
