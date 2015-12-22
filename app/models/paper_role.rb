class PaperRole < ActiveRecord::Base
  include EventStream::Notifiable

  REVIEWER = 'reviewer'
  EDITOR = 'editor'
  COLLABORATOR = 'collaborator'
  ADMIN = 'admin'
  PARTICIPANT = 'participant'

  ALL_ROLES = [REVIEWER, EDITOR, COLLABORATOR, ADMIN, PARTICIPANT]

  belongs_to :user,  inverse_of: :paper_roles
  belongs_to :paper, inverse_of: :paper_roles

  validates :paper, presence: true
  validates :user,  presence: true

  validates :old_role, uniqueness: {
    scope: [:user_id, :paper_id],
    message: "already assigned to this user"
  }

  validate :old_role_exists

  def self.admins
    where(old_role: ADMIN)
  end

  def self.for_user(user)
    where(user: user)
  end

  def self.editors
    where(old_role: EDITOR)
  end

  def self.reviewers
    where(old_role: REVIEWER)
  end

  def self.collaborators
    where(old_role: COLLABORATOR)
  end

  def self.participants
    where(old_role: PARTICIPANT)
  end

  def self.for_old_role(old_role)
    where(old_role: old_role)
  end

  def self.reviewers_for(paper)
    reviewers.where(paper_id: paper.id)
  end

  def self.most_recent_for(user)
    select("paper_id, max(created_at) as max_created").for_user(user).group(:paper_id).order("max_created DESC")
  end

  def description
    old_role.capitalize
  end

  private

  def old_role_exists
    return unless paper.journal

    errors.add(:base, "Invalid old_role provided") unless old_role.in?(paper.journal.valid_old_roles)
  end
end
