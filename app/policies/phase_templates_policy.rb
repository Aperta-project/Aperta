class PhaseTemplatesPolicy < ApplicationPolicy
  require_params :phase_template

  def create?
    can_administer_journal? journal
  end

  def update?
    can_administer_journal? journal
  end

  def destroy?
    can_administer_journal? journal
  end

  private

  def journal
    phase_template.manuscript_manager_template.try(:journal)
  end
end
