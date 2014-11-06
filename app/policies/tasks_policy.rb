class TasksPolicy < ApplicationPolicy
  primary_resource :task

  include TaskAccessCriteria

  def connected_users
    #TODO: this is the same as the paper connected_users.  remove duplication.
    [paper.user, paper.assigned_users, paper.tasks.flat_map(&:participants)].flatten.uniq
  end

  def show?
    authorized_to_modify_task?
  end

  def create?
    authorized_to_create_task?
  end

  def update?
    authorized_to_modify_task?
  end

  def upload?
    authorized_to_modify_task?
  end

  def destroy?
    authorized_to_modify_task?
  end

  def send_message?
    authorized_to_modify_task?
  end
end
