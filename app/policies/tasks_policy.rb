class TasksPolicy < ApplicationPolicy
  allow_params :task
  include TaskAccessCriteria

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
