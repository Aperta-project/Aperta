class CommentsPolicy < ApplicationPolicy
  require_params :task
  include TaskAccessCriteria

  def show?
    authorized_to_modify_task?
  end

  def create?
    authorized_to_modify_task?
  end
end
