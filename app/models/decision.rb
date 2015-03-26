class Decision < ActiveRecord::Base
  belongs_to :paper

  before_save :increment_revision_number

  def increment_revision_number
    # TODO: refactor to a simpler method
    increment(:revision_number, paper.latest_decision ? paper.latest_decision.revision_number + 1 : 0)
  end
end
