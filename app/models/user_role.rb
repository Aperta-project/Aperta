class UserRole < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :user, inverse_of: :user_roles
  belongs_to :role, inverse_of: :user_roles

  validates :user, presence: true
  validates :role, presence: true

  validates :role_id, uniqueness: { scope: :user_id }

  def self.admins
    joins(:role).merge(Role.admins)
  end

  def self.editors
    joins(:role).merge(Role.editors)
  end

  def self.reviewers
    joins(:role).merge(Role.reviewers)
  end

  def self.academic_editors
    joins(:role).merge(Role.academic_editors)
  end
end
