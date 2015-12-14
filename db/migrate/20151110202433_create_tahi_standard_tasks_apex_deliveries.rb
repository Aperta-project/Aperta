#
# Adds ApexDelivery as a way to track the progress of manuscripts' final export
# to Apex.
#
class CreateTahiStandardTasksApexDeliveries < ActiveRecord::Migration
  def change
    create_table :tahi_standard_tasks_apex_deliveries do |t|
      t.integer :paper_id
      t.integer :task_id
      t.integer :user_id
      t.string :state
      t.string :error_message
      t.timestamps
    end
  end
end
