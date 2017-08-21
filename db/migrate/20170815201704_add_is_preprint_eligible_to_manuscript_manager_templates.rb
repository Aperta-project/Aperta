class AddIsPreprintEligibleToManuscriptManagerTemplates < ActiveRecord::Migration
  def up
    add_column :manuscript_manager_templates, :is_preprint_eligible, :boolean, default: false
  end

  def down
    remove_column :manuscript_manager_templates, :is_preprint_eligible, :boolean, default: false
  end
end
