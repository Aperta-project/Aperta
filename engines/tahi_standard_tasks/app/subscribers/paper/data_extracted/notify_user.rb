class Paper::DataExtracted::NotifyUser < FlashMessageSubscriber
  def user
    Paper.find(@event_data[:record].paper_id).creator
  end

  def message_type
    if @event_data[:record].completed?
      'success'
    elsif @event_data[:record].errored?
      'error'
    end
  end

  def message
    if @event_data[:record].completed?
      'Finished loading Word file.'
    elsif @event_data[:record].errored?
      'There was an error loading your Word file.'
    end
  end
end
