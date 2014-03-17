class TaskSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :title, :type, :completed, :message_subject
  has_one :phase
  has_many :assignees, serializer: UserSerializer, include: true, root: :users
  has_one :assignee, serializer: UserSerializer, include: true, root: :users
end
