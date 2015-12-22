class FlowsPolicy < ApplicationPolicy
  primary_resource :flow

  def show?
    can_administer_journal?(journal)
  end

  def create?
    can_administer_journal?(journal)
  end

  def update?
    can_administer_journal?(journal)
  end

  def destroy?
    can_administer_journal?(journal)
  end

  private

  def journal
    flow.old_role.journal
  end
end
