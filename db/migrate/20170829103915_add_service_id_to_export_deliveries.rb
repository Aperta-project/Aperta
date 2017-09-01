class AddServiceIdToExportDeliveries < ActiveRecord::Migration
  def change
    add_column :tahi_standard_tasks_export_deliveries, :service_id, :string
  end
end
