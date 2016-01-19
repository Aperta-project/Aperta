# Emails new participants in a discussion
# rubocop:disable ClassAndModuleChildren
class DiscussionParticipant::Created::EmailNewParticipant
  def self.call(_event_name, event_data)
    participant = event_data[:record]
    UserMailer.delay.notify_added_to_topic(participant.user_id,
                                           participant.discussion_topic_id)
  end
end
