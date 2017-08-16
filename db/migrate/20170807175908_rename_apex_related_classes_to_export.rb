class RenameApexRelatedClassesToExport < ActiveRecord::Migration
  def change
    rename_table :tahi_standard_tasks_apex_deliveries, :tahi_standard_tasks_export_deliveries
  end
end
