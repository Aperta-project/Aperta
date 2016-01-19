# Emails people mentioned in a forum reply
# rubocop:disable ClassAndModuleChildren
class DiscussionReply::Created::EmailPeopleMentioned
  def self.call(_event_name, event_data)
    reply = event_data[:record]

    people_mentioned = UserMentions.new(reply.body,
                                        reply.replier).people_mentioned
    people_mentioned.each do |mentionee|
      UserMailer.delay.notify_mention_in_discussion(mentionee.id,
                                                    reply.discussion_topic.id,
                                                    reply.id)
    end
  end
end
