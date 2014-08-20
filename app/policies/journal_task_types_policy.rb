class JournalTaskTypesPolicy < ApplicationPolicy
  require_params :journal_task_type

  def update?
    current_user.admin? || can_administer_journal?(journal_task_type.journal)
  end
end
