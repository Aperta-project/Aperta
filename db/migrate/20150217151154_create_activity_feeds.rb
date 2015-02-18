class CreateActivityFeeds < ActiveRecord::Migration
  def change
    create_table :activity_feeds do |t|
      t.string :feed_name
      t.integer :subject_id
      t.string :subject_type
      t.string :activity_key
      t.string :message
      t.integer :user_id
      t.timestamps
    end

    add_index :activity_feeds, :user_id
    add_index :activity_feeds, :subject_id
    add_index :activity_feeds, :subject_type
  end
end
