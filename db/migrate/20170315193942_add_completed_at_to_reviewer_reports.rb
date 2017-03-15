class AddCompletedAtToReviewerReports < ActiveRecord::Migration
  def change
    add_column :reviewer_reports, :completed_at, :datetime
  end
end
