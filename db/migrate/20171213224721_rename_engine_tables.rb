class RenameEngineTables < ActiveRecord::Migration
  def change
    rename_table "tahi_standard_tasks_export_deliveries", "export_deliveries"
    rename_table "tahi_standard_tasks_reviewer_recommendations", "reviewer_recommendations"
  end
end
