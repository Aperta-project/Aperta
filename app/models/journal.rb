class Journal < ActiveRecord::Base
  VALID_TASK_TYPES = ["ReviewerReportTask",
                      "PaperAdminTask",
                      "MessageTask",
                      "StandardTasks::TechCheckTask",
                      "StandardTasks::FigureTask",
                      "UploadManuscriptTask",
                      "PaperEditorTask",
                      "FigureTask",
                      "DeclarationTask",
                      "Task",
                      "PaperReviewerTask",
                      "RegisterDecisionTask",
                      "StandardTasks::AuthorsTask"]

  has_many :papers, inverse_of: :journal
  has_many :journal_roles, inverse_of: :journal
  has_many :users, through: :journal_roles
  has_many :manuscript_manager_templates

  def admins
    users.merge(JournalRole.admins)
  end

  def editors
    users.merge(JournalRole.editors)
  end

  def reviewers
    users.merge(JournalRole.reviewers)
  end

  def logo_url
    logo.url if logo
  end

  def paper_types
    self.manuscript_manager_templates.pluck(:paper_type)
  end

  mount_uploader :logo, LogoUploader
end
