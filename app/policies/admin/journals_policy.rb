class Admin::JournalsPolicy < ApplicationPolicy
  def index?
    can_administer_any_journal?
  end

  def update?
    can_administer_any_journal?
  end

  def upload_epub_cover?
    can_administer_any_journal?
  end
end
