class ManuscriptManagerTemplate < ActiveRecord::Base
  #TODO: Remove these and change the tests' references.
  VALID_TASK_TYPES = ["ReviewerReportTask",
                      "PaperAdminTask",
                      "MessageTask",
                      "StandardTasks::TechCheckTask",
                      "UploadManuscriptTask",
                      "PaperEditorTask",
                      "FigureTask",
                      "DeclarationTask",
                      "Task",
                      "PaperReviewerTask",
                      "RegisterDecisionTask",
                      "StandardTasks::AuthorsTask"]

  validates :name, :paper_type, presence: true
  belongs_to :journal

  validate :no_duplicate_phase_names
  validate :task_types_in_whitelist

  private

  def phases
    template["phases"] || []
  end

  def task_types
    phases.flat_map { |phase| phase["task_types"] }.compact.uniq
  end

  def no_duplicate_phase_names
    names = phases.map { |phase| phase["name"] }
    unless names.length == names.uniq.length
      errors.add(:phases, "Phases cannot have duplicate names")
    end
  end

  def task_types_in_whitelist
    if task_types.present? && task_types.any? { |task_type| !VALID_TASK_TYPES.include? task_type }
      errors.add(:task_types, "Task types must be in the allowed list")
    end
  end

end
