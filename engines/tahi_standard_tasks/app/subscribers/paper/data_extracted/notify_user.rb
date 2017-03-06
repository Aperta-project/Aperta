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
      message = "Finished loading #{pdf_type? ? 'PDF' : 'Word'} file."
      unless pdf_type?
        addendum = ' Any figures included in the file will have been removed' \
                   ' should now be uploaded directly by clicking \'Figures\'.'
        message.concat(addendum)
      end
      message
    elsif @event_data[:record].errored?
      "There was an error loading your #{pdf_type? ? 'PDF' : 'Word'} file."
    end
  end

  private

  def pdf_type?
    @event_data[:record].recipe_name == 'pdf_to_html'
  end
end
