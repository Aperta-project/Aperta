class TasksPolicy < ApplicationPolicy
  primary_resource :task

  include TaskAccessCriteria

  def connected_users
    PapersPolicy.new(current_user: current_user, resource: task.paper).connected_users
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
