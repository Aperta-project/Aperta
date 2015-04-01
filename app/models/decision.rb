class Decision < ActiveRecord::Base
  belongs_to :paper

  before_validation :increment_revision_number

  validates :revision_number, uniqueness: { scope: :paper_id }
  validates :verdict, presence: true

  def self.latest
    order("revision_number DESC").first
  end

  def increment_revision_number
    unless persisted?
      # TODO: refactor to a simpler method
      increment(:revision_number, paper.latest_decision ? paper.latest_decision.revision_number + 1 : 0)
    end
  end
end
