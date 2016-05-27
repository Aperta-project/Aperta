class AdminJournalSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :logo_url,
             :paper_types,
             :pdf_css,
             :manuscript_css,
             :description,
             :doi_publisher_prefix,
             :doi_journal_prefix,
             :last_doi_issued,
             :paper_count,
             :created_at
  has_many :manuscript_manager_templates, embed: :ids, include: true
  has_many :old_roles, embed: :ids, include: true
  has_many :journal_task_types, embed: :ids, include: true

  def paper_count
    object.papers.count
  end

  def journal_task_types
    # TODO: refactor this woraround with a more general solution in this ticket:
    # https://developer.plos.org/jira/browse/APERTA-5490
    exluded_types = ['PlosBioTechCheck::ChangesForAuthorTask',
                     'TahiStandardTasks::ReviewerReportTask',
                     'TahiStandardTasks::ReviseTask']

    object.journal_task_types.where.not(kind: exluded_types)
  end

end
