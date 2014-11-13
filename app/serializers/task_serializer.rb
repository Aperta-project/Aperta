class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :body, :paper_title, :role
  has_one :phase, embed: :id
  has_one :paper, embed: :id
  has_one :lite_paper, embed: :id, include: true, serializer: LitePaperSerializer, user: :scoped_user

  has_many :attachments, embed: :ids, include: true
  has_many :questions, embed: :ids, include: true
  has_many :comments, embed: :ids, include: true
  has_many :participations, embed: :ids, include: true

  self.root = :task

  def paper_title
    object.paper.display_title
  end

  def lite_paper
    object.paper
  end

  private

  def scoped_user
    scope.presence || options[:user]
  end
end
