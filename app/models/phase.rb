class Phase < ActiveRecord::Base
  belongs_to :task_manager

  DEFAULT_PHASE_NAMES = [
    "Needs Editor",
    "Needs Reviewer",
    "Needs Review",
    "Needs Decision"
  ]

  def self.default_phases
    DEFAULT_PHASE_NAMES.map { |name| Phase.new name: name }
  end
end
