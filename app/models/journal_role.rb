class JournalRole < ActiveRecord::Base
  belongs_to :user, inverse_of: :journal_roles
  belongs_to :journal, inverse_of: :journal_roles
  belongs_to :role, inverse_of: :journal_roles

  validates :user, :journal, presence: true

  def self.admins
    joins(:role).where('roles.admin' => true)
  end

  def self.editors
    joins(:role).where('roles.editor' => true)
  end

  def self.reviewers
    joins(:role).where('roles.reviewer' => true)
  end
end
