class AddServiceIdToApexDeliveries < ActiveRecord::Migration
  def change
    add_column :tahi_standard_tasks_apex_deliveries, :service_id, :string
  end
end
