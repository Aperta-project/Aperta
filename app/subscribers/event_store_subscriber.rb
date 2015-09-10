class EventStoreSubscriber
  attr_reader :record, :event_name

  def self.call(event_name, event_data)
    subscriber = new(event_name, event_data)
    subscriber.save!
  end

  def initialize(event_name, event_data)
    @event_name = event_name
    @record = event_data[:record]
  end

  def save!
    with_logging do
      event.save!
    end
  end

  def event
    @event ||= build_event.tap { |event|
      event.name      = formatted_event_name
      event.record    = record
      event.timestamp = DateTime.now
    }
  end

  def build_event
    raise NotImplementedError.new("You must build a base EventStore object")
  end

  private

  def with_logging(&blk)
    EventStoreSubscriber.logger.tagged("EventStore") do
      EventStoreSubscriber.logger.info { "Storing `#{formatted_event_name}` to EventStore with #{event.attributes}" }
      yield
    end
  end

  def self.logger
    @logger ||= ActiveSupport::TaggedLogging.new(Rails.logger)
  end

  def formatted_event_name
    # remove application namespacing
    event_name.gsub(/^.+?:/, '')
  end
end
