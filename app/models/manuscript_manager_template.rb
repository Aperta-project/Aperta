class ManuscriptManagerTemplate < ActiveRecord::Base
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
  validate :task_type_in_whitelist

  def phases
    template["phases"] || []
  end

  def task_types
    phases.flat_map { |phase| phase["task_types"] }.uniq
  end

  def no_duplicate_phase_names
    names = phases.map { |phase| phase["name"] }
    unless names.length == names.uniq.length
      errors.add(:phases, "Phases cannot have duplicate names")
    end
  end

  def task_type_in_whitelist
    unless task_types.all? { |task_type| VALID_TASK_TYPES.include? task_type }
      errors.add(:task_types, "Task types must be in the allowed list")
    end
  end

end
