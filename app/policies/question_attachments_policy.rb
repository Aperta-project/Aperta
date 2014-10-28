class QuestionAttachmentsPolicy < ApplicationPolicy
  require_params :task
  include TaskAccessCriteria

  def destroy?
    authorized_to_modify_task?
  end
end
