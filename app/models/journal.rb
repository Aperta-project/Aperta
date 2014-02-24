class Journal < ActiveRecord::Base
  has_many :papers
  has_many :journal_roles
  has_many :users, through: :journal_roles

  def admins
    users.where('journal_roles.admin' => true)
  end

  def editors
    users.where('journal_roles.editor' => true)
  end

  def reviewers
    users.where('journal_roles.reviewer' => true)
  end

  mount_uploader :logo, LogoUploader
end
