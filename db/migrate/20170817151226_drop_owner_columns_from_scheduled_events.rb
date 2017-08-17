class DropOwnerColumnsFromScheduledEvents < ActiveRecord::Migration
  def change
    remove_column :scheduled_events, :owner_id, :integer
    remove_column :scheduled_events, :owner_type, :string
  end
end
