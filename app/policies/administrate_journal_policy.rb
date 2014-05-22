class AdministrateJournalPolicy < ApplicationPolicy

  def index?
    super_admin? || administered_journals.exists?
  end

end
