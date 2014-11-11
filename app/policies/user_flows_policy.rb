class UserFlowsPolicy < ApplicationPolicy
  def index?
    can_view_flow_manager?
  end

  def show?
    can_view_flow_manager?
  end

  def create?
    can_view_flow_manager?
  end

  def update?
    can_view_flow_manager?
  end

  def destroy?
    can_view_flow_manager?
  end

  def authorization?
    can_view_flow_manager?
  end

  def serializer
    if super_admin?
      UserFlowSerializer
    elsif can_administer_any_journal?
      JournalAdminFlowSerializer
    end
  end
end
