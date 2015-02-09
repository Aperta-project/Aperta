class Phase < ActiveRecord::Base
  has_many :tasks, inverse_of: :phase, dependent: :destroy
  belongs_to :paper, inverse_of: :phases
  has_one :journal, through: :paper

  acts_as_list scope: :paper

  DEFAULT_PHASE_NAMES = [
    "Submission Data",
    "Invite Editor",
    "Assign Reviewers",
    "Get Reviews",
    "Make Decision"
  ]

  def self.default_phases
    DEFAULT_PHASE_NAMES.map.with_index { |name, pos| Phase.new name: name, position: pos + 1 }
  end
end
