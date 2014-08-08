class AdminJournalSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :logo_url,
             :paper_types,
             :epub_cover_url,
             :epub_cover_file_name,
             :epub_css,
             :pdf_css,
             :manuscript_css,
             :description,
             :paper_count,
             :created_at
  has_many :manuscript_manager_templates, include: true
  has_many :roles, embed: :ids, include: true
  has_many :journal_task_types, embed: :ids, include: true

  def paper_count
    object.papers.count
  end

end
