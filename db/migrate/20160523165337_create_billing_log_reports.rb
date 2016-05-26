class CreateBillingLogReports < ActiveRecord::Migration
  def change
    create_table :billing_log_reports do |t|
      t.string     :csv_file
      t.date       :from_date
      t.timestamps
    end
  end
end
