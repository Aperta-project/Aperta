class AdminJournalSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :logo_url,
    :paper_types,
    :pdf_css,
    :manuscript_css,
    :description,
    :paper_count,
    :created_at,
    :pdf_allowed,
    :doi_journal_prefix,
    :doi_publisher_prefix,
    :last_doi_issued,
    :links
  has_many :admin_journal_roles,
           embed: :ids,
           include: true,
           serializer: AdminJournalRoleSerializer
  has_many :journal_task_types, embed: :ids, include: true

  def paper_count
    object.papers.count
  end

  def admin_journal_roles
    object.roles
  end

  def journal_task_types
    object.journal_task_types.where(system_generated: false)
  end

  def links
    template_path = journal_manuscript_manager_templates_path(object)
    {
      manuscript_manager_templates: template_path,
      cards: journal_cards_path(object)
    }
  end
end
