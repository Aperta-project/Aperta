class DiscussionReply < ActiveRecord::Base

  belongs_to :discussion_topic, inverse_of: :discussion_replies
  belongs_to :replier, inverse_of: :discussion_replies, class_name: 'User'

end
