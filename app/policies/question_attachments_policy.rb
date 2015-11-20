class QuestionAttachmentsPolicy < ApplicationPolicy
  primary_resource :question_attachment

  include TaskAccessCriteria

  def show?
    authorized_to_modify_task?
  end

  def destroy?
    authorized_to_modify_task?
  end

  private

  def task
    question_attachment.nested_question_answer.owner
  end

  def tasks_policy
    @tasks_policy ||= TasksPolicy.new(current_user: current_user, resource: task)
  end
end
