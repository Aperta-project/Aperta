class Notification::Unbadger

  def self.call(_event_name, event_data)
    discussion_participant = event_data[:record]
    discussion_topic = discussion_participant.discussion_topic

    # do not use destroy_all, we need callbacks to fire
    discussion_topic.notifications.where(user: discussion_participant.user).all.map(&:destroy!)
  end

end
