class RemoveManumanTemplateName < ActiveRecord::Migration
  def change
    remove_column :manuscript_manager_templates, :name
  end
end
