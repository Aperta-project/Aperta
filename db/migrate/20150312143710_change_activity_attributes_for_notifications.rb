class ChangeActivityAttributesForNotifications < ActiveRecord::Migration
  def change
    rename_column :activities, :feed_name, :event_scope
    rename_column :activities, :activity_key, :event_action
    rename_column :activities, :subject_type, :target_type
    rename_column :activities, :subject_id, :target_id
    rename_column :activities, :user_id, :actor_id
    remove_column :activities, :message
  end
end
