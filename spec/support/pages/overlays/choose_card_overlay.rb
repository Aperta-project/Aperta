class ChooseCardOverlay < CardOverlay
  def create_message
    find('#overlay button.message').click
  end

  def create_task
    find('#overlay button.task').click
  end

end
