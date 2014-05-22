class ManuscriptManagerTemplatePolicy < ApplicationPolicy
  require_params :journal

  def index?
    can_administer_journal?
  end

  def show?
    can_administer_journal?
  end

  def update?
    can_administer_journal?
  end

  def create?
    can_administer_journal?
  end

  def destroy?
    can_administer_journal?
  end

  private

  def can_administer_journal?
    current_user.admin? || administered_journals.exists?(journal)
  end

  def administered_journals
    Journal.joins(:journal_roles => :role)
      .merge(Role.can_administer_journal)
      .where('journal_roles.user_id' => current_user)
  end
end
