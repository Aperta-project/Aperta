class ResolveSchemaIssues < ActiveRecord::Migration
  def change
    remove_column :journals, :last_preprint_doi_issued, :string, default: "0", null: false
    change_column_default :tahi_standard_tasks_export_deliveries, :destination, nil
  end
end
