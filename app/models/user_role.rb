class UserRole < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_roles
  belongs_to :role, inverse_of: :user_roles

  validates :user, presence: true

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
