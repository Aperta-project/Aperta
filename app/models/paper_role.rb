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

  validates_uniqueness_of :role, scope: [:user_id, :paper_id]
  validate :role_exists

  def self.admins
    where(role: ADMIN)
  end

  def self.for_user(user)
    where(user: user)
  end

  def self.editors
    where(role: EDITOR)
  end

  def self.reviewers
    where(role: REVIEWER)
  end

  def self.collaborators
    where(role: COLLABORATOR)
  end

  def self.participants
    where(role: PARTICIPANT)
  end

  def self.for_role(role)
    where(role: role)
  end

  def self.reviewers_for(paper)
    reviewers.where(paper_id: paper.id)
  end

  def self.most_recent_for(user)
    select("paper_id, max(created_at) as max_created").for_user(user).group(:paper_id).order("max_created DESC")
  end

  def description
    role.capitalize
  end

  private

  def role_exists
    errors.add(:base, "Invalid role provided") unless role.in?(valid_roles)
  end

  def valid_roles
    ALL_ROLES | paper.journal.roles.map(&:name)
  end
end
