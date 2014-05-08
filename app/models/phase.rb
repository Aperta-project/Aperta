class Phase < ActiveRecord::Base
  has_many :tasks, inverse_of: :phase
  has_many :message_tasks, -> { where(type: 'MessageTask') }, inverse_of: :phase
  belongs_to :paper

  acts_as_list scope: :paper

  DEFAULT_PHASE_NAMES = [
    "Submission Data",
    "Assign Editor",
    "Assign Reviewers",
    "Get Reviews",
    "Make Decision"
  ]

  def self.default_phases
    DEFAULT_PHASE_NAMES.map.with_index { |name, pos| Phase.new name: name, position: pos + 1 }
  end
end
