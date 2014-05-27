class Journal < ActiveRecord::Base
  VALID_TASK_TYPES = ["ReviewerReportTask",
                      "PaperAdminTask",
                      "UploadManuscript::Task",
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
  has_many :roles, inverse_of: :journal
  has_many :manuscript_manager_templates

  def admins
    User.joins(:journal_roles => :role).merge(Role.admins).where('journal_roles.journal_id' => self.id)
  end

  def editors
    User.joins(:journal_roles => :role).merge(Role.editors).where('journal_roles.journal_id' => self.id)
  end

  def reviewers
    User.joins(:journal_roles => :role).merge(Role.reviewers).where('journal_roles.journal_id' => self.id)
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
