class RemoveNullEmailConstraint < ActiveRecord::Migration
  def up
    change_column_null( :tahi_standard_tasks_reviewer_recommendations, :email, true )
  end

  def down
    change_column_null( :tahi_standard_tasks_reviewer_recommendations, :email, false )
  end
end
