class AssignmentsPolicy < ApplicationPolicy
  require_params :paper

  def index?
    can_administer_journal? paper.journal
  end

  def create?
    can_administer_journal? paper.journal
  end

  def destroy?
    can_administer_journal? paper.journal
  end
end
