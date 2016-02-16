class UserRole < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :user, inverse_of: :user_roles
  belongs_to :old_role, inverse_of: :user_roles

  validates :user, presence: true
  validates :old_role, presence: true

  validates :old_role_id, uniqueness: { scope: :user_id }

  def self.admins
    joins(:old_role).merge(OldRole.admins)
  end

  def self.reviewers
    joins(:old_role).merge(OldRole.reviewers)
  end
end
