class AdminJournalSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :paper_types, :task_types
  has_many :manuscript_manager_templates, include: true
  has_many :roles, embed: :ids, include: true

  def task_types
    Journal::VALID_TASK_TYPES
  end
end
