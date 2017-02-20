class AddUniqIndexToReviewerReports < ActiveRecord::Migration
  def change
    add_index(:reviewer_reports, [:task_id, :user_id, :decision_id], unique: true, name: 'one_report_per_round')
  end
end
