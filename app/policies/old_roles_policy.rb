class OldRolesPolicy < ApplicationPolicy

  allow_params :old_role
  require_params :journal

  def index?
    can_administer_journal?(journal)
  end

  def show?
    if old_role
      can_administer_journal?(journal) || old_role.member?(current_user)
    else
      can_administer_journal?(journal)
    end
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

end
