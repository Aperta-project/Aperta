# This class deals with pushing out notifications to users related to
# the success or failure of manuscript uploads
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
      'Finished loading Word file.'\
      ' Any figures included in the file will have been removed' \
      ' and should now be uploaded directly' \
      ' by clicking \'Figures\'.'
    elsif @event_data[:record].errored?
      "There was an error loading your #{pdf_type? ? 'PDF' : 'Word'} file."
    end
  end

end
