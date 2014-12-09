class Admin::JournalsPolicy < ApplicationPolicy
  primary_resource :journal

  def index?
    can_administer_any_journal?
  end

  def show?
    can_administer_journal?(journal)
  end

  def authorization?
    can_administer_any_journal?
  end

  def create?
    super_admin?
  end

  def upload_logo?
    can_administer_journal?(journal)
  end

  def upload_epub_cover?
    can_administer_journal?(journal)
  end

  def update?
    can_administer_journal?(journal)
  end
end
