class AdministrateJournalPolicy < ApplicationPolicy

  def index?
    current_user.admin? || administered_journals.exists?
  end

  def administered_journals
    Journal.joins(:journal_roles => :role).merge(Role.can_administer_journal).where('journal_roles.user_id' => current_user)
  end

end
