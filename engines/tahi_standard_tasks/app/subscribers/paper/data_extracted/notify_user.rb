class Paper::DataExtracted::NotifyUser < FlashMessageSubscriber
  def user
    User.find(@event_data[:record].user_id)
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
      'Finished loading Word file. Any images that had been included'\
      ' in the manuscript should be uploaded directly to the figures card.'
    elsif @event_data[:record].errored?
      'There was an error loading your Word file.'
    end
  end
end
