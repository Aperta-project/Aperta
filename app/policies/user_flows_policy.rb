class UserFlowsPolicy < ApplicationPolicy
  allow_params :flow

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
end
