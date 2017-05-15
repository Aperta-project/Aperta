class AddNumberReviewerReportsToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :number_reviewer_reports, :boolean, null: false, default: false, index: true
  end
end
