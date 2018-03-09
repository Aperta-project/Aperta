class AdminJournalSerializer < AuthzSerializer
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
    :links,
    :letter_template_scenarios
  has_many :admin_journal_roles,
           embed: :ids,
           include: true,
           serializer: AdminJournalRoleSerializer
  has_many :journal_task_types, embed: :ids, include: true
  has_many :card_task_types, embed: :ids, include: true

  def paper_count
    object.papers.count
  end

  def admin_journal_roles
    object.roles
  end

  def card_task_types
    CardTaskType.all
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

  def letter_template_scenarios
    TemplateContext.scenarios.map { |name, klass| { name: name, merge_fields: klass.merge_fields } }
  end

  def can_view?
    scope.can?(:administer, journal)
  end
end
