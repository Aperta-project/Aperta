class TasksPolicy < ApplicationPolicy
  primary_resource :task
  allow_params :for_paper

  include TaskAccessCriteria

  def index?
    can_view_paper? for_paper
  end

  def questions?
    authorized_to_modify_task?
  end

  def comments?
    authorized_to_modify_task?
  end

  def participations?
    authorized_to_modify_task?
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

  def nested_questions?
    authorized_to_modify_task?
  end

  def nested_question_answers?
    authorized_to_modify_task?
  end
end
