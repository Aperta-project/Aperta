class RolesPolicy < ApplicationPolicy

  allow_params :role
  require_params :journal

  def index?
    can_administer_journal?(journal)
  end

  def show?
    if role
      can_administer_journal?(journal) || role.member?(current_user)
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
