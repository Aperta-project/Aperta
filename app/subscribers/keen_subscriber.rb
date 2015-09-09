class KeenSubscriber
  attr_reader :event_name, :record

  def self.call(event_name, event_data)
    subscriber = new(event_name, event_data)
    subscriber.run
  end

  def initialize(event_name, event_data)
    @event_name = event_name
    @record = event_data[:record]
  end

  def run
    final_payload = default_payload.merge(payload)
    log(@event_name, final_payload)
    # using sidekiq rather than keen async to remain consistent with other subscribers
    Keen.delay.publish(collection, final_payload)
  end

  def default_payload
    {
      keen: { timestamp: DateTime.now.utc },
      event_name: event_name.gsub(/^.:/, '') # remove internal application prefix from event name
    }
  end

  def payload
    raise NotImplementedError.new("You must define the data that is sent to keen")
  end

  def collection
    raise NotImplementedError.new("You must define the collection name for keen")
  end

  private

  def log(event_name, event_data)
    KeenSubscriber.logger.tagged("KeenIO") do
      KeenSubscriber.logger.info { "Sending #{event_name} to Keen. data: #{event_data.inspect}" }
    end
  end

  def self.logger
    @logger ||= ActiveSupport::TaggedLogging.new(Rails.logger)
  end

end
