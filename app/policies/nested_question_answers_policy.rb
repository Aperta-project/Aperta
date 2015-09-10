class NestedQuestionAnswersPolicy < ApplicationPolicy
  require_params :nested_question_answer
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
    nested_question_answer.owner
  end
end
