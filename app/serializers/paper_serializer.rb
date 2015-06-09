class PaperSerializer < LitePaperSerializer
  # TODO Inheriting from LitePaper since we need related_at_date and roles so that
  # the dashboard updates correctly when the event stream triggers
  attributes :id, :short_title, :title, :doi, :body, :submitted, :paper_type, :status, :updated_at, :editable, :links

  %i(phases figures tables authors supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: true
  end

  # these are the people that have actually been assigned to roles on the paper.
  %i(editors reviewers).each do |relation|
    has_many relation, embed: :ids, include: true, root: :users
  end

  has_many :collaborations, embed: :ids, include: true, serializer: CollaborationSerializer
  has_many :decisions, embed: :ids, include: true, serializer: DecisionSerializer
  has_many :tasks, embed: :ids, polymorphic: true
  has_one :journal, embed: :id, include: true
  has_one :locked_by, embed: :id, include: true, root: :users
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
    { comment_looks: comment_looks_paper_path(object) }
  end

end
