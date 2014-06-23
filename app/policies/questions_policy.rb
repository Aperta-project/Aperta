class QuestionsPolicy < ApplicationPolicy
  require_params :question

  def create?
    super_admin? || author_of_paper?(question.task.paper)
  end

  def update?
    super_admin? || author_of_paper?(question.task.paper)
  end

end
