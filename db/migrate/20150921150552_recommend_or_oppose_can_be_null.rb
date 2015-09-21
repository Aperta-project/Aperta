class RecommendOrOpposeCanBeNull < ActiveRecord::Migration
  def up
    change_column_null( :tahi_standard_tasks_reviewer_recommendations, :recommend_or_oppose, true )
  end

  def down
    change_column_null( :tahi_standard_tasks_reviewer_recommendations, :recommend_or_oppose, false )
  end
end
