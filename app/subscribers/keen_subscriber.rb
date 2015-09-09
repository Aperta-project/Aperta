class KeenSubscriber
  attr_reader :action, :record

  def self.call(event_name, event_data)
    subscriber = new(event_name, event_data)
    subscriber.run
  end

  def initialize(_event_name, event_data)
    @action = event_data[:action]
    @record = event_data[:record]
  end

  def run
    # using sidekiq rather than keen async to remain consistent with other subscribers
    Keen.delay.publish(collection, payload.merge(keen: { timestamp: DateTime.now.utc }))
  end

  def payload
    raise NotImplementedError.new("You must define the data that is sent to keen")
  end

  def collection
    raise NotImplementedError.new("You must define the collection name for keen")
  end
end
