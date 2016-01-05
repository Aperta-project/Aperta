class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :paper_id, :user_id, :target_type, :target_id
end
