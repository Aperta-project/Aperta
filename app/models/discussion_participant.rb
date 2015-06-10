class DiscussionParticipant < ActiveRecord::Base
  belongs_to :discussion_topic, inverse_of: :discussion_participants
  belongs_to :user, inverse_of: :discussion_participants
end
