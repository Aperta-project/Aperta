# Adds timestamps to MMT, for display on the admin workflow catalogue
class AddCreationUpdateTimestampsToManuscriptManagerTemplates < ActiveRecord::Migration
  def change
    add_column :manuscript_manager_templates, :updated_at, :datetime
    add_column :manuscript_manager_templates, :created_at, :datetime

    now = Time.zone.now
    ManuscriptManagerTemplate.update_all(created_at: now, updated_at: now)
  end
end
