class FlowsPolicy < ApplicationPolicy
  def index?
    can_administer_any_journal?
  end

  def create?
    can_administer_any_journal?
  end

  def destroy?
    can_administer_any_journal?
  end

  def serializer
    if super_admin?
      FlowSerializer
    elsif can_administer_any_journal?
      JournalAdminFlowSerializer
    end
  end
end
