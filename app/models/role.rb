class Role < ActiveRecord::Base

  ADMIN    = "admin"
  EDITOR   = "editor"
  REVIEWER = "reviewer"
  CUSTOM   = "custom"

  REQUIRED_KINDS = [ADMIN, EDITOR, REVIEWER]
  KINDS = REQUIRED_KINDS + [CUSTOM]

  belongs_to :journal, inverse_of: :roles
  has_many :user_roles, inverse_of: :role
  has_many :users, through: :user_roles

  validates :name, presence: true
  validates :name, uniqueness: { scope: :journal_id }
  validates :kind, inclusion: KINDS

  before_destroy :prevent_destroying_required_role

  def self.admins
    where(kind: ADMIN)
  end

  def self.editors
    where(kind: EDITOR)
  end

  def self.reviewers
    where(kind: REVIEWER)
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

  private

  def prevent_destroying_required_role
    if required?
      errors.add(:base, "This role is required. It may not be deleted.")
      false
    end
  end
end
