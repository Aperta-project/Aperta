class PaperSerializer < LitePaperSerializer
  # TODO Inheriting from LitePaper since we need related_at_date and
  # roles so that the dashboard updates correctly when the event
  # stream triggers
  attributes :id, :short_title, :title, :doi, :body,
             :publishing_state, :paper_type, :status, :updated_at,
             :editable, :links, :is_submitted

  %i(tables bibitems supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: true
  end

  has_many :collaborations, embed: :ids, include: true, serializer: CollaborationSerializer
  # has_many :decisions, embed: :ids, include: true, serializer: DecisionSerializer
  has_one :journal, embed: :id
  has_one :locked_by, embed: :id
  has_one :striking_image, embed: :id

  def is_submitted
    object.submitted?
  end

  def status
    object.manuscript.try(:status)
  end

  def collaborations
    # we want the actual join record, not a list of users
    object.paper_roles.collaborators
  end

  def links
    {
      comment_looks: comment_looks_paper_path(object),
      tasks: paper_tasks_path(object),
      phases: paper_phases_path(object),
      figures: paper_figures_path(object),
      versioned_texts: versioned_texts_paper_path(object),
      discussion_topics: paper_discussion_topics_path(object),
      decisions: paper_decisions_path(object)
    }
  end
end
