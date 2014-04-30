class JournalRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :journal

  def self.admin
    where(admin: true)
  end
end
