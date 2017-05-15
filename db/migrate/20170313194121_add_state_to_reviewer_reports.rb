class AddStateToReviewerReports < ActiveRecord::Migration
  def self.up
    add_column :reviewer_reports, :state, :string
  end

  def self.down
    remove_column :reviewer_reports, :state
  end
end
