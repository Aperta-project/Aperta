class Decision < ActiveRecord::Base
  belongs_to :paper
  has_many :invitations

  before_validation :increment_revision_number

  default_scope { order('revision_number DESC') }

  validates :revision_number, uniqueness: { scope: :paper_id }

  def self.latest
    first
  end

  def latest?
    self == paper.latest_decision
  end

  def increment_revision_number
    unless persisted?
      # TODO: refactor to a simpler method
      increment(:revision_number, paper.latest_decision ? paper.latest_decision.revision_number + 1 : 0)
    end
  end
end
