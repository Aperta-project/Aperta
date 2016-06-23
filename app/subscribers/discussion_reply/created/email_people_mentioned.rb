# Emails people mentioned in a forum reply
# rubocop:disable ClassAndModuleChildren
class DiscussionReply::Created::EmailPeopleMentioned
  def self.call(_event_name, event_data)
    reply = event_data[:record]
    notifiable_users_mentioned = reply.user_mentions.notifiable_users_mentioned
    notifiable_users_mentioned.each do |mentionee|
      UserMailer.delay.notify_mention_in_discussion(mentionee.id,
                                                    reply.discussion_topic.id,
                                                    reply.id)
    end
  end
end
