class Phase < ActiveRecord::Base
  belongs_to :task_manager
  has_many :tasks

  has_one :paper, through: :task_manager

  after_initialize :initialize_defaults

  DEFAULT_PHASE_NAMES = [
    "Submission Data",
    "Assign Editor",
    "Assign Reviewers",
    "Get Reviews",
    "Make Decision"
  ]

  def self.default_phases
    DEFAULT_PHASE_NAMES.map { |name| Phase.new name: name }
  end

  private

  def initialize_defaults
    return unless tasks.empty?
    case name
    when 'Submission Data'
      self.tasks << UploadManuscriptTask.new
      self.tasks << AuthorsTask.new
      self.tasks << FigureTask.new
      self.tasks << DeclarationTask.new
    when 'Assign Editor'
      self.tasks << PaperAdminTask.new
      self.tasks << TechCheckTask.new
      self.tasks << PaperEditorTask.new
    when 'Assign Reviewers'
      self.tasks << PaperReviewerTask.new
    when 'Make Decision'
      self.tasks << RegisterDecisionTask.new
    end
  end
end
