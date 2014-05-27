class JournalPolicy < ApplicationPolicy

  allow_params :journal

  def index?
    true
  end

  def show?
    super_admin? || can_administer_journal?(journal)
  end

end
