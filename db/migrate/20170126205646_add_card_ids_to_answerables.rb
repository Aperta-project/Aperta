class AddCardIdsToAnswerables < ActiveRecord::Migration
  def change
    add_column :authors, :card_id, :integer, index: true
    add_column :group_authors, :card_id, :integer, index: true
    add_column :tahi_standard_tasks_funders, :card_id, :integer, index: true
    add_column :tahi_standard_tasks_reviewer_recommendations, :card_id, :integer, index: true
  end
end
