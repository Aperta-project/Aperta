class DropScheduledEventsTemplate < ActiveRecord::Migration
  def change
    drop_table :scheduled_event_templates, if_exists: true
  end
end
