class DiscussionTopic < ActiveRecord::Base

  belongs_to :paper, inverse_of: :discussion_topics

  has_many :discussion_participants, inverse_of: :discussion_topic, dependent: :destroy
  has_many :participants, through: :discussion_participants, source: :user, class_name: 'User'
  has_many :discussion_replies, inverse_of: :discussion_topic, dependent: :destroy

  def self.including(user)
    includes(:discussion_participants).where(discussion_participants: { user_id: user.id })
  end

end
