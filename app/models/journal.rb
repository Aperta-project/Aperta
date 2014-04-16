class Journal < ActiveRecord::Base
  has_many :papers, inverse_of: :journal
  has_many :journal_roles
  has_many :users, through: :journal_roles
  has_many :manuscript_manager_templates

  def admins
    users.where('journal_roles.admin' => true)
  end

  def editors
    users.where('journal_roles.editor' => true)
  end

  def reviewers
    users.where('journal_roles.reviewer' => true)
  end

  def logo_url
    logo.url if logo
  end

  def paper_types
    ["Research", "Presubmission"]
  end

  mount_uploader :logo, LogoUploader
end
