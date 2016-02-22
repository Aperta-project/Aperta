class DiscussionTopic < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :paper, inverse_of: :discussion_topics

  has_many :discussion_participants, inverse_of: :discussion_topic, dependent: :destroy
  has_many :participants, through: :discussion_participants, source: :user, class_name: 'User'
  has_many :discussion_replies, inverse_of: :discussion_topic, dependent: :destroy
  has_many :notifications, as: :target
  has_many :assignments, as: :assigned_to
  has_one :journal, through: :paper

  def self.including(user)
    includes(:discussion_participants).where(discussion_participants: { user_id: user.id })
  end

  def has_participant?(user)
    participants.include? user
  end

  def add_discussion_participant(discussion_participant)
    assignments.create(
      user: discussion_participant.user,
      role: journal.discussion_participant_role
    )
    discussion_participant.save
  end

  def remove_discussion_participant(discussion_participant)
    assignments.find_by(
      user: discussion_participant.user,
      role: journal.discussion_participant_role
    ).try(&:destroy)
    discussion_participant.destroy
  end
end
