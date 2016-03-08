# Paper tracker queries are saved searches; they let the user re-run
# common-but-hard-tocompose queries, and share those queries with
# others.
class CreatePaperTrackerQueryTable < ActiveRecord::Migration
  def change
    create_table :paper_tracker_queries do |t|
      t.string :query
      t.string :title
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
  end
end
