# A single class to trigger "events"

class Event
  # Single method to call to start a method.
  def self.trigger(name, paper:, user:, task: nil)
    raise ArgumentError if user.nil?
    raise ArgumentError if paper.nil?

    # Broadcast it
    Notifier.notify(event: name, data: { paper: paper, task: task })

    # Run handlers
    EventBehavior.where(event_name: name).each do |action|
      action.call(paper: paper, task: task, user: user)
    end

    # Log to the activity feed
    Activity.create(
      feed_name: "forensic",
      activity_key: name,
      subject: task || paper,
      user: user
    )
  end
end