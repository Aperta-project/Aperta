# A single class to trigger "events"

class Event
  def self.register(*events)
    @events ||= []
    events.map(&:to_s).each do |event|
      @events << event unless @events.member?(event)
    end
  end

  def self.deregister(*events)
    events.map(&:to_s).each do |event|
      @events.delete(event)
    end
  end

  def self.allowed_events
    return [] if @events.nil?
    @events.dup
  end

  def self.allowed?(event)
    @events.member?(event.to_s)
  end

  # Single method to call to start a method.
  def self.trigger(name, paper:, user:, task: nil, **rest)
    raise ArgumentError if paper.nil?
    raise ArgumentError unless Event.allowed?(name)

    # Broadcast it
    Notifier.notify(event: name, data: { paper: paper, task: task }.merge(rest))

    # Run handlers
    EventBehavior.where(event_name: name).each do |action|
      action.call(paper: paper, task: task, user: user)
    end

    # Log to the activity feed
    Activity.create(
      feed_name: "forensic",
      activity_key: name,
      subject: task || paper,
      user: user,
      message: rest[:event_message]
    )
  end
end
