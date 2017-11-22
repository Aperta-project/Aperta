# A single class to trigger "events"

class Event
  # Register event names.
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

  def self.allowed_events_including_descendants
    allowed_events + descendants.flat_map(&:allowed_events)
  end

  def self.allowed?(event)
    @events.member?(event.to_s)
  end

  attr_accessor :name, :paper, :task, :user

  def initialize(name:, paper:, task:, user:)
    @name = name
    @paper = paper
    @task = task
    @user = user
  end

  # Single method to call to start a method.
  def trigger
    raise ArgumentError, "A paper is required" if paper.nil?
    raise ArgumentError, "Event #{name} not registered" unless self.class.allowed?(name)
    raise StandardError, "Event #{self} already triggered" if @triggered

    # Run handlers
    Behavior.where(event_name: name).each { |behavior| behavior.call(self) }

    # Broadcast it
    Notifier.notify(event: name, data: notify_payload)

    # Log to the activity feed
    Activity.create!(**activity_feed_payload)
    @triggered = true
  end

  private

  def notify_payload
    { paper: paper, task: task }
  end

  def activity_feed_payload
    {
      feed_name: "forensic",
      activity_key: name,
      subject: task || paper,
      user: user,
      message: activity_feed_message
    }
  end

  def activity_feed_message
    "#{name} triggered"
  end
end
