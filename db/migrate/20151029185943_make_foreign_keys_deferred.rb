class MakeForeignKeysDeferred < ActiveRecord::Migration
  def up
    change_column :decisions, :paper_id, :integer, foreign_key: { references: :paper, deferrable: true }
    change_column :discussion_participants, :discussion_topic_id, :integer, foreign_key: { references: :discussion_participant, deferrable: true }
    change_column :discussion_participants, :user_id, :integer, foreign_key: { references: :user, deferrable: true }
    change_column :discussion_replies, :discussion_topic_id, :integer, foreign_key: { references: :discussion_topic, deferrable: true }
    change_column :discussion_topics, :paper_id, :integer, foreign_key: { references: :paper, deferrable: true }
    change_column :questions, :decision_id, :integer, foreign_key: { references: :decision, deferrable: true }
  end

  def down
    change_column :decisions, :paper_id, :integer, foreign_key: { references: :paper, deferrable: false }
    change_column :discussion_participants, :discussion_topic_id, :integer, foreign_key: { references: :discussion_participant, deferrable: false }
    change_column :discussion_participants, :user_id, :integer, foreign_key: { references: :user, deferrable: false }
    change_column :discussion_replies, :discussion_topic_id, :integer, foreign_key: { references: :discussion_topic, deferrable: false }
    change_column :discussion_topics, :paper_id, :integer, foreign_key: { references: :paper, deferrable: false }
    change_column :questions, :decision_id, :integer, foreign_key: { references: :decision, deferrable: false }
  end
end
