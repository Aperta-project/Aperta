class TaskSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :title, :type, :completed, :message_subject, :parent_type
  has_one :phase
  has_many :assignees, serializer: UserSerializer, include: true, root: :users
  has_one :assignee, serializer: UserSerializer, include: true, root: :users

  def parent_type
    'task'
  end

end
