class RemoveNotNullConstraintOnRecommendOrOppose < ActiveRecord::Migration
  def change
    change_column :tahi_standard_tasks_reviewer_recommendations, :recommend_or_oppose, :string, null: true
  end
end
