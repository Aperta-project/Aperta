class NestedQuestionAnswersPolicy < ApplicationPolicy
  primary_resource :nested_question_answer
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
    if nested_question_answer.owner.respond_to?(:task)
      nested_question_answer.owner.task
    elsif nested_question_answer.owner.is_a?(Task)
      nested_question_answer.owner
    else
      raise NotImplementedError, "Don't know how to check authorization to NestedQuestionAnswer for #{nested_question_answer.owner.inspect}. You may need to implement this."
    end
  end
end
