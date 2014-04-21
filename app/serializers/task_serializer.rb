class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :body, :paper_title, :role
  has_one :phase, embed: :id
  has_many :assignees, embed: :ids, include: true, root: :users
  has_one :assignee, embed: :ids, include: true, root: :users

  self.root = :task

  def paper_title
    object.paper.display_title
  end
end
