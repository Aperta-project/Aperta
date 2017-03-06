# Add status columns for keeping review status
class AddStatusAndStatusDatetimeToReviewerReports < ActiveRecord::Migration
  def change
    add_column :reviewer_reports, :status, :string
    add_column :reviewer_reports, :status_datetime, :datetime
  end
end
