class CreateDiscussionParticipants < ActiveRecord::Migration
  def change
    create_table :discussion_participants do |t|
      t.references :discussion_topic, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
