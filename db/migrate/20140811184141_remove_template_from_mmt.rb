class RemoveTemplateFromMmt < ActiveRecord::Migration
  def change
    remove_column :manuscript_manager_templates, :template, :json
  end
end
