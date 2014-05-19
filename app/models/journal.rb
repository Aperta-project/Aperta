class Journal < ActiveRecord::Base
  VALID_TASK_TYPES = ["ReviewerReportTask",
                      "PaperAdminTask",
                      "UploadManuscriptTask",
                      "PaperEditorTask",
                      "DeclarationTask",
                      "PaperReviewerTask",
                      "RegisterDecisionTask",
                      "StandardTasks::TechCheckTask",
                      "StandardTasks::FigureTask",
                      "StandardTasks::AuthorsTask",
                      "SupportingInformation::Task"]

  has_many :papers, inverse_of: :journal
  has_many :journal_roles, inverse_of: :journal
  has_many :users, through: :journal_roles
  has_many :manuscript_manager_templates

  def admins
    users.merge(JournalRole.admins).uniq
  end

  def editors
    users.merge(JournalRole.editors).uniq
  end

  def reviewers
    users.merge(JournalRole.reviewers).uniq
  end

  def logo_url
    logo.url if logo
  end

  def paper_types
    self.manuscript_manager_templates.pluck(:paper_type)
  end

  def mmt_for_paper_type(paper_type)
    manuscript_manager_templates.where(paper_type: paper_type).first
  end

  mount_uploader :logo, LogoUploader
end
