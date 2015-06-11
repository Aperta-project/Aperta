class RolesPolicy < ApplicationPolicy

  require_params :journal

  def index?
    can_administer_journal?(journal)
  end

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

end
