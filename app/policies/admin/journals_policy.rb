class Admin::JournalsPolicy < ApplicationPolicy

  def index?
    can_administer_any_journal?
  end

end
