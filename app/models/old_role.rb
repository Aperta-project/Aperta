class OldRole < ActiveRecord::Base

  ADMIN    = "admin"
  EDITOR   = "editor"
  CUSTOM   = "custom"

  REQUIRED_KINDS = [ADMIN, EDITOR]
  KINDS = REQUIRED_KINDS + [CUSTOM]

  belongs_to :journal, inverse_of: :old_roles
  has_many :user_roles, inverse_of: :old_role, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true
  validates :name, uniqueness: { scope: :journal_id }
  validates :kind, inclusion: KINDS

  before_destroy :prevent_destroying_required_role

  def self.admins
    where(kind: ADMIN)
  end

  def required?
    REQUIRED_KINDS.include?(kind)
  end

  def self.can_administer_journal
    where(can_administer_journal: true)
  end

  def self.can_view_all_manuscript_managers
    where(can_view_all_manuscript_managers: true)
  end

  def self.can_view_assigned_manuscript_managers
    where(can_view_assigned_manuscript_managers: true)
  end

  def label
    "#{journal.name} #{name}"
  end

  def member?(user)
    return false if user.nil?

    users.where(id: user.id).exists?
  end

  private

  def prevent_destroying_required_role
    return true if journal.blank? || journal.marked_for_destruction?
    if required?
      errors.add(:base, "This old_role is required. It may not be deleted.")
      false
    end
  end
end
