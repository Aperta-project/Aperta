class AdminJournalSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :paper_types, :task_types, :epub_cover_url, :epub_cover_file_name
  has_many :manuscript_manager_templates, include: true
  has_many :roles, embed: :ids, include: true

  def task_types
    Journal::VALID_TASK_TYPES
  end
end
