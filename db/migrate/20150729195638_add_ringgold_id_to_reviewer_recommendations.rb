class AddRinggoldIdToReviewerRecommendations < ActiveRecord::Migration
  def change
    add_column :tahi_standard_tasks_reviewer_recommendations, :ringgold_id, :string
  end
end
