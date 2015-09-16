class EventLogger

  def self.call(event_name, event_data)
    logger.tagged("EventLog") do
      logger.info { "#{event_name} received with: #{event_data.inspect}" }
    end
  end

  def self.logger
    @logger ||= ActiveSupport::TaggedLogging.new(Rails.logger)
  end

end
