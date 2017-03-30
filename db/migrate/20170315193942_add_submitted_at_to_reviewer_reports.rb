class AddSubmittedAtToReviewerReports < ActiveRecord::Migration
  def change
    add_column :reviewer_reports, :submitted_at, :datetime
  end
end
