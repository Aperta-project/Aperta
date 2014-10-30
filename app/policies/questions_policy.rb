class QuestionsPolicy < ApplicationPolicy
  require_params :question
  include TaskAccessCriteria

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
    question.task
  end
end
