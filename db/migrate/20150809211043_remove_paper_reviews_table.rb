class RemovePaperReviewsTable < ActiveRecord::Migration
  def up
    drop_table :paper_reviews
  end

  def down
    create_table "paper_reviews", force: :cascade do |t|
      t.integer  "task_id"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
