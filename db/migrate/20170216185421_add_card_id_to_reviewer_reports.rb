class AddCardIdToReviewerReports < ActiveRecord::Migration
  def change
    add_column :reviewer_reports, :card_id, :integer, index: true
  end
end
