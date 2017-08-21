class AddColumnsToPaperTrackerQueries < ActiveRecord::Migration
  def change
    add_column :paper_tracker_queries, :order_dir, :string
    add_column :paper_tracker_queries, :order_by, :string
  end
end
