class Decision < ActiveRecord::Base
  belongs_to :paper

  before_validation :increment_revision_number

  validates_uniqueness_of :revision_number, scope: :paper_id

  def increment_revision_number
    unless persisted?
      # TODO: refactor to a simpler method
      increment(:revision_number, paper.latest_decision ? paper.latest_decision.revision_number + 1 : 0)
    end
  end
end
