class DiscussionReply < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :discussion_topic, inverse_of: :discussion_replies
  belongs_to :replier, inverse_of: :discussion_replies, class_name: 'User'

  after_save :notify_mentioned_people

  def notify_mentioned_people
    people_mentioned = UserMentions.new(body, replier).people_mentioned
    people_mentioned.each do |mentionee|
      UserMailer.notify_mention_in_discussion(mentionee.id, id)
        .deliver_later
    end
  end
end
