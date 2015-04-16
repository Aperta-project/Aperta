class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :doi, :body, :submitted, :paper_type, :status, :updated_at, :editable

  %i(phases figures authors supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: true
  end

  # these are the people that have actually been assigned to roles on the paper.
  %i(editors reviewers).each do |relation|
    has_many relation, embed: :ids, include: true, root: :users
  end

  has_many :collaborations, embed: :ids, include: true, serializer: CollaborationSerializer
  has_many :decisions, embed: :ids, include: true, serializer: DecisionSerializer
  has_one :lite_paper, embed: :id, include: :true, user: :scoped_user, serializer: LitePaperSerializer
  has_many :tasks, embed: :ids, polymorphic: true
  has_many :decisions, embed: :ids, include: true, serializer: DecisionSerializer
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

  def lite_paper
    object
  end

  def scoped_user
    scope.presence || options[:user]
  end
end
