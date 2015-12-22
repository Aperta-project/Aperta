class UserRolesPolicy < ApplicationPolicy
  primary_resource :user_role

  def index?
    can_administer_journal?(journal)
  end

  def create?
    can_administer_journal?(journal)
  end

  def show?
    can_administer_journal?(journal)
  end

  def destroy?
    can_administer_journal?(journal)
  end

  private

  def journal
    user_role.old_role.journal
  end
end
