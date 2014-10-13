class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :body, :submitted, :paper_type, :status, :event_name, :editable

  %i(phases figures authors supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: true
  end

  %i(assignees editors reviewers).each do |relation|
    has_many relation, embed: :ids, include: true, root: :users
  end

  has_many :tasks, embed: :ids, polymorphic: true
  has_one :journal, embed: :id, include: true
  has_one :locked_by, embed: :id, include: true, root: :users
  has_many :collaborations, embed: :ids, include: true, serializer: CollaborationSerializer
  has_one :striking_image, embed: :id, include: true, root: :figures

  def status
    object.manuscript.try(:status)
  end

  def editors
    object.editors.includes(:affiliations)
  end

  def assignees
    object.assignees.includes(:affiliations)
  end

  def reviewers
    object.reviewers.includes(:affiliations)
  end

  def collaborations
    # we want the actual join record, not a list of users
    object.paper_roles.collaborators
  end

  def event_name
    # used by new paper collaborators to subscribe to future paper events
    EventStream.stream_names(object)
  end
end
