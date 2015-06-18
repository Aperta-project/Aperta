class CreateDiscussionTopics < ActiveRecord::Migration
  def change
    create_table :discussion_topics do |t|
      t.string :title
      t.references :paper, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
