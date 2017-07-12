class DropSimpleReports < ActiveRecord::Migration
  def change
    drop_table :simple_reports, {}
  end
end
