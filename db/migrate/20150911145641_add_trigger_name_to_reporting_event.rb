class AddTriggerNameToReportingEvent < ActiveRecord::Migration
  def change
    add_column :reporting_events, :trigger_name, :string
  end
end
