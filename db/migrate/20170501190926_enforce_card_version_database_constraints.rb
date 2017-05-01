class EnforceCardVersionDatabaseConstraints < ActiveRecord::Migration
  def up
    change_column :authors, :card_version_id, :integer, null: false
    change_column :group_authors, :card_version_id, :integer, null: false
    change_column :reviewer_reports, :card_version_id, :integer, null: false
    change_column :tahi_standard_tasks_funders, :card_version_id, :integer, null: false
    change_column :tahi_standard_tasks_reviewer_recommendations, :card_version_id, :integer, null: false
    change_column :tasks, :card_version_id, :integer, null: false
  end

  def down
    change_column :tasks, :card_version_id, :integer, null: true
    change_column :tahi_standard_tasks_reviewer_recommendations, :card_version_id, :integer, null: true
    change_column :tahi_standard_tasks_funders, :card_version_id, :integer, null: true
    change_column :reviewer_reports, :card_version_id, :integer, null: true
    change_column :group_authors, :card_version_id, :integer, null: true
    change_column :authors, :card_version_id, :integer, null: true
  end
end
