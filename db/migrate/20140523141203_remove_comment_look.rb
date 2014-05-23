class RemoveCommentLook < ActiveRecord::Migration
  def change
    drop_table :comment_looks

  end

  def down
    create_table "comment_looks", force: true do |t|
      t.integer  "user_id"
      t.integer  "comment_id"
      t.datetime "read_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "comment_looks", ["comment_id"], name: "index_comment_looks_on_comment_id", using: :btree
    add_index "comment_looks", ["user_id"], name: "index_comment_looks_on_user_id", using: :btree
  end
end
