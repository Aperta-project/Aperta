class PaperSerializer < LitePaperSerializer
  # TODO Inheriting from LitePaper since we need related_at_date and
  # roles so that the dashboard updates correctly when the event
  # stream triggers
  attributes :id, :short_title, :title, :doi, :body,
             :publishing_state, :paper_type, :status, :updated_at,
             :editable, :links, :versions, :manuscript_id

  %i(figures tables bibitems authors supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: true
  end

  # these are the people that have actually been assigned to roles on the paper.
  %i(editors reviewers).each do |relation|
    has_many relation, embed: :ids, include: true, root: :users
  end

  has_many :collaborations, embed: :ids, include: true, serializer: CollaborationSerializer
  has_many :decisions, embed: :ids, include: true, serializer: DecisionSerializer
  # has_many :tasks, embed: :ids, polymorphic: true
  has_one :journal, embed: :id, include: true
  has_one :striking_image, embed: :id, include: true, root: :figures

  def status
    object.manuscript.try(:status)
  end

  def editors
    object.editors.includes(:affiliations)
  end

  def reviewers
    object.reviewers.includes(:affiliations)
  end

  def collaborations
    # we want the actual join record, not a list of users
    object.paper_roles.collaborators
  end

  def links
    {
      comment_looks: comment_looks_paper_path(object),
      tasks: paper_tasks_path(object),
      phases: paper_phases_path(object)
    }
  end

  def versions
    object.versioned_texts.version_desc.map do |v|
      { name: v.version_string,
        id: v.id }
    end
  end
end
