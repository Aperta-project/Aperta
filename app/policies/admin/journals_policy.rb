class Admin::JournalsPolicy < ApplicationPolicy
  def index?
    can_administer_any_journal?
  end

  def show?
    can_administer_any_journal?
  end

  def authorization?
    index?
  end

  def create?
    super_admin?
  end

  def upload_logo?
    can_administer_any_journal?
  end

  def upload_epub_cover?
    can_administer_any_journal?
  end

  def update?
    can_administer_any_journal?
  end
end
