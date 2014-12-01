class RoleFlowsPolicy < ApplicationPolicy
  primary_resource :role_flow

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
    role_flow.role.journal
  end
end
