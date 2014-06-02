class UserRole < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_roles
  belongs_to :role, inverse_of: :user_roles

  validates :user, presence: true

  def self.admins
    joins(:role).merge(Role.admins)
  end

  def self.editors
    joins(:role).merge(Role.editors)
  end

  def self.reviewers
    joins(:role).merge(Role.reviewers)
  end
end
