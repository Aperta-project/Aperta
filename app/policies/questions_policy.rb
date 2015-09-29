class QuestionsPolicy < ApplicationPolicy
  require_params :question
  allow_params :for_task
  include TaskAccessCriteria

  def index?
    authorized_to_modify_task?
  end

  def create?
    authorized_to_modify_task?
  end

  def update?
    authorized_to_modify_task?
  end

  def destroy?
    authorized_to_modify_task?
  end

  private

  def task
    for_task || question.task
  end
end
