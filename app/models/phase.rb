class Phase < ActiveRecord::Base
  belongs_to :task_manager
  has_many :tasks

  delegate :paper, to: :task_manager

  after_initialize :initialize_defaults

  DEFAULT_PHASE_NAMES = [
    "Submit Paper",
    "Needs Editor",
    "Needs Reviewer",
    "Needs Review",
    "Needs Decision"
  ]

  def self.default_phases
    DEFAULT_PHASE_NAMES.map { |name| Phase.new name: name }
  end

  private

  def initialize_defaults
    return unless tasks.empty?
    case name
    when 'Submit Paper'
      self.tasks << DeclarationTask.new
      self.tasks << FigureTask.new
    when 'Needs Editor'
      self.tasks << PaperAdminTask.new
      self.tasks << TechCheckTask.new
      self.tasks << PaperEditorTask.new
    when 'Needs Reviewer'
      self.tasks << PaperReviewerTask.new
    when 'Needs Decision'
      self.tasks << RegisterDecisionTask.new
    end
  end
end
