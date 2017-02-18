# Column to aid with rollback of APERTA-7993
class AddAperta7993MigrationColumnToReviewerReports < ActiveRecord::Migration
  def change
    add_column :reviewer_reports, :created_in_7993, :boolean, default: false
  end
end
