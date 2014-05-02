class JournalRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :journal

  def self.admins
    where(admin: true)
  end

  def self.editors
    where(editor: true)
  end

  def self.reviewers
    where(reviewer: true)
  end
end
