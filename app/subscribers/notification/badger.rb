class Notification::Badger

  def self.call(_event_name, event_data)
    discussion_participant = event_data[:record]
    discussion_topic = discussion_participant.discussion_topic
    discussion_topic.notifications.where(paper: discussion_topic.paper, user: discussion_participant.user).first_or_create!
  end

end
