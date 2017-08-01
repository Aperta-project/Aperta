class OwningScheduledEvents < ActiveRecord::Migration
  def change
    remove_column :scheduled_event_templates, :owner_id, :integer
    add_column :scheduled_events, :owner_type, :string
    add_column :scheduled_events, :owner_id, :integer
  end
end
