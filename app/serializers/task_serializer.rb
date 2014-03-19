class TaskSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :title, :type, :completed, :message_subject, :parent_type, :body
  has_one :phase
  has_many :assignees, embed: :ids, include: true
  has_one :assignee, embed: :ids, include: true

  def parent_type
    'task'
  end

end
