class ReportingEventSubscriber
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
      event.kind      = record.class.name # fully namespaced class (https://github.com/rails/rails/issues/20893)
      event.timestamp = DateTime.now
    }
  end

  def build_event
    raise NotImplementedError.new("You must build a base ReportingEvent object")
  end

  private

  def with_logging(&blk)
    ReportingEventSubscriber.logger.tagged("ReportingEvent") do
      ReportingEventSubscriber.logger.info { "Storing `#{formatted_event_name}` to ReportingEvents with #{event.attributes}" }
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
