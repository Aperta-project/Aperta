class AdminJournalSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :logo_url,
             :paper_types,
             :pdf_css,
             :manuscript_css,
             :description,
             :paper_count,
             :created_at
  has_many :manuscript_manager_templates, embed: :ids, include: true
  has_many :old_roles, embed: :ids, include: true
  has_many :admin_journal_roles, embed: :ids, include: true
  has_many :journal_task_types, embed: :ids, include: true

  def paper_count
    object.papers.count
  end

  def admin_journal_roles
    object.roles.where(assigned_to_type_hint: "Journal")
  end

  def journal_task_types
    # TODO: refactor this workaround as per this ticket:
    # https://developer.plos.org/jira/browse/APERTA-5490
    excluded_types = ['PlosBioTechCheck::ChangesForAuthorTask',
                     'TahiStandardTasks::ReviewerReportTask',
                     'TahiStandardTasks::ReviseTask']

    object.journal_task_types.where.not(kind: excluded_types)
  end

end
