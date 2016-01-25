class PaperSerializer < LitePaperSerializer
  attributes :id, :short_title, :title, :doi, :body,
             :publishing_state, :paper_type, :updated_at,
             :editable, :links, :manuscript_id, :created_at, :editable,
             :submitted_at, :gradual_engagement

  %i(tables bibitems supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: true
  end

  has_many :collaborations,
           embed: :ids,
           include: true,
           serializer: CollaborationSerializer

  has_one :journal, embed: :id
  has_one :striking_image, embed: :id

  def collaborations
    # we want the actual join record, not a list of users
    object.participations
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
      snapshots: snapshots_paper_path(object)
    }
  end
end
