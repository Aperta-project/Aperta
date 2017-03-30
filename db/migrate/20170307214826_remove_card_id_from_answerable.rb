# With card versions Answerables should point to a version
# rather than the Card, which can be looked up easily in
# the rare event it's actually needed directly
class RemoveCardIdFromAnswerable < ActiveRecord::Migration
  def change
    remove_column :tasks, :card_id, :integer, index: true
    remove_column :authors, :card_id, :integer, index: true
    remove_column :group_authors, :card_id, :integer, index: true
    remove_column :reviewer_reports, :card_id, :integer, index: true
    remove_column :tahi_standard_tasks_funders, :card_id, :integer, index: true
    remove_column :tahi_standard_tasks_reviewer_recommendations, :card_id, :integer, index: true

    add_column :tasks, :card_version_id, :integer, index: true
    add_column :authors, :card_version_id, :integer, index: true
    add_column :group_authors, :card_version_id, :integer, index: true
    add_column :reviewer_reports, :card_version_id, :integer, index: true
    add_column :tahi_standard_tasks_funders, :card_version_id, :integer, index: true
    add_column :tahi_standard_tasks_reviewer_recommendations, :card_version_id, :integer, index: true
  end
end
