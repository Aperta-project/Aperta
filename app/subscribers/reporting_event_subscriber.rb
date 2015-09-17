class ReportingEventSubscriber
  attr_reader :record, :trigger_name

  def self.call(trigger_name, event_data)
    subscriber = new(trigger_name, event_data)
    subscriber.save!
  end

  def initialize(trigger_name, event_data)
    @trigger_name = trigger_name
    @record = event_data[:record]
  end

  def save!
    with_logging do
      event.save!
    end
  end

  def event
    @event ||= build_event.tap { |event|
      event.trigger_name = trigger_name
      event.record = record
      event.kind = record.class.name # fully namespaced class (https://github.com/rails/rails/issues/20893)
      event.timestamp = DateTime.now
    }
  end

  def build_event
    raise NotImplementedError.new("You must build a base ReportingEvent object")
  end

  private

  def with_logging(&blk)
    ReportingEventSubscriber.logger.tagged("ReportingEvent") do
      ReportingEventSubscriber.logger.info { "Storing `#{event.name}` due to `#{event.trigger_name}` with #{event.attributes}" }
      yield
    end
  end

  def self.logger
    @logger ||= ActiveSupport::TaggedLogging.new(Rails.logger)
  end
end
