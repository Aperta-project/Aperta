# This serializes invite_queues, which hold queues of invitations to be sent out
# according to specified rules
class InviteQueueSerializer < ActiveModel::Serializer
  attributes :id, :queue_title
  has_one :task, embed: :id, polymorphic: true
end
