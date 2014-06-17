class Admin::JournalsPolicy < ApplicationPolicy
  def index?
    can_administer_any_journal?
  end

  def create?
    can_administer_any_journal?
  end

  def update?
    can_administer_any_journal?
  end
end
