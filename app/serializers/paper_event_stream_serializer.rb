# TODO: change this after the other serializer stuff is all finished.
class PaperEventStreamSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :body, :submitted, :paper_type, :status, :updated_at, :editable
  root :paper

  %i(phases figures authors supporting_information_files).each do |relation|
    has_many relation, embed: :ids, include: false
  end

  %i(editors reviewers).each do |relation|
    has_many relation, embed: :ids, include: false, root: :users
  end

  has_many :tasks, embed: :ids, polymorphic: true
  has_many :collaborations, embed: :ids, include: true, serializer: CollaborationSerializer
  has_one :journal, embed: :ids, include: false
  has_one :locked_by, embed: :id, include: true, root: :users
  has_one :striking_image, embed: :id, include: true, root: :figures
  has_one :lite_paper, embed: :id, include: :true, user: :scoped_user, serializer: LitePaperSerializer

  def collaborations
    # we want the actual join record, not a list of users
    object.paper_roles.collaborators
  end

  def status
    object.manuscript.try(:status)
  end

  def lite_paper
    object
  end

  def scoped_user
    scope.presence || options[:user]
  end
end
