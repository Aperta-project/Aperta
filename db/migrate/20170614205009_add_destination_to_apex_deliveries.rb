class AddDestinationToApexDeliveries < ActiveRecord::Migration
  def change
    add_column :tahi_standard_tasks_apex_deliveries, :destination, :string, null: false, default: 'apex'
  end
end
