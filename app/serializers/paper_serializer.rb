class PaperSerializer < LitePaperSerializer
  attributes :id, :short_title, :title, :doi, :body, :abstract,
             :publishing_state, :paper_type, :updated_at,
             :editable, :links, :manuscript_id, :created_at, :editable,
             :submitted_at, :gradual_engagement,
             :versions_contain_pdf, :legends_allowed, :current_user_roles,
             :manually_similarity_checked, :aarx_doi

  %i(supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: true
  end

  has_one :creator,
    embed: :id,
    include: true,
    root: :users,
    serializer: SensitiveInformationUserSerializer

  has_many :collaborations,
           embed: :ids,
           include: true,
           serializer: AssignmentSerializer

  has_many :correspondence,
  embed: :ids,
  include: true,
  serializer: CorrespondenceSerializer

  has_one :journal, embed: :id
  has_one :striking_image, embed: :id
  has_one :file, embed: :object, serializer: AttachmentSerializer
  has_one :sourcefile, embed: :object, serializer: AttachmentSerializer

  def aarx_doi
    object.aarx_doi
    # is this necessary
  end

  def paper_task_types
    paper.journal.journal_task_types
  end

  def versions_contain_pdf
    object.versioned_texts.any? { |vt| vt.file_type == "pdf" }
  end

  def current_user_roles
    return [] unless scope
    Role.where(journal_id: object.journal).joins(:assignments)
    .where("assignments.user_id = ?", scope).pluck(:name).uniq
  end

  def links
    {
      comment_looks: comment_looks_paper_path(object),
      tasks: paper_tasks_path(object),
      phases: paper_phases_path(object),
      figures: paper_figures_path(object),
      versioned_texts: versioned_texts_paper_path(object),
      discussion_topics: paper_discussion_topics_path(object),
      decisions: paper_decisions_path(object),
      snapshots: snapshots_paper_path(object),
      related_articles: related_articles_paper_path(object),
      correspondence: paper_correspondence_index_path(object),
      paper_task_types: paper_task_types_path(object),
      # all possible Cards that can be added to this Paper
      available_cards: paper_available_cards_path(object),
      similarity_checks: paper_similarity_checks_path(object)
    }
  end
end
