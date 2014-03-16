class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :message_subject
  has_one :phase, embed: :ids
end
