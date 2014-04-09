class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :parent_type, :body, :paper_title, :role
  has_one :phase, embed: :id, include: true
  has_many :assignees, embed: :ids, include: true, root: :users
  has_one :assignee, embed: :ids, include: true, root: :users

  def parent_type
    'task'
  end

  def paper_title
    object.paper.display_title
  end
end
