class CreateDiscussionReplies < ActiveRecord::Migration
  def change
    create_table :discussion_replies do |t|
      t.text :body
      t.references :discussion_topic, index: true, foreign_key: true
      t.integer :replier_id, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
