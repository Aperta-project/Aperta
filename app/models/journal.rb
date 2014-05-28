class Journal < ActiveRecord::Base
  VALID_TASK_TYPES = ["ReviewerReportTask",
                      "PaperAdminTask",
                      "UploadManuscript::Task",
                      "PaperEditorTask",
                      "Declaration::Task",
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

  mount_uploader :logo,       LogoUploader
  mount_uploader :epub_cover, EpubCoverUploader

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

  def epub_cover_url
    epub_cover.url if epub_cover
  end

  def epub_cover_uploaded_at
    return nil unless epub_cover.file

    if Rails.application.config.carrierwave_storage == :fog
      epub_cover.file.send('file').last_modified
    else
      File.mtime epub_cover.file.path
    end
  end

  def paper_types
    self.manuscript_manager_templates.pluck(:paper_type)
  end

  def mmt_for_paper_type(paper_type)
    manuscript_manager_templates.where(paper_type: paper_type).first
  end
end
