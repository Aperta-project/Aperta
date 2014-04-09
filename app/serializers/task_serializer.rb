class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :parent_type, :body, :paper_title, :role
  has_one :phase, embed: :id
  has_many :assignees, embed: :ids, include: true, root: :users
  has_one :assignee, embed: :ids, include: true, root: :users

  def parent_type
    'task'
  end

  def type
    # Client doesn't need to know about the task's namespace.
    object.type.gsub(/.+::/,'')
  end

  def paper_title
    object.paper.display_title
  end

end
