class ManuscriptManagerTemplatesPolicy < ApplicationPolicy
  require_params :manuscript_manager_template

  def show?
    can_administer_journal?(journal)
  end

  def update?
    can_administer_journal?(journal)
  end

  def create?
    can_administer_journal?(journal)
  end

  def destroy?
    can_administer_journal?(journal)
  end

  private

  def journal
    manuscript_manager_template.journal
  end
end
