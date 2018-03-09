class NotificationSerializer < AuthzSerializer
  attributes :id, :paper_id, :user_id, :target_type, :target_id, :parent_type, :parent_id
end
