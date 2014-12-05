class UserRolesPolicy < ApplicationPolicy
  primary_resource :user_role

  def connected_users
    (journal.admins + User.site_admins).uniq
  end

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
    user_role.role.journal
  end
end
