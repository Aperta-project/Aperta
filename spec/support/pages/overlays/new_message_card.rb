class NewMessageCardOverlay < CardOverlay

  def self.launch(session)
    overlay = session.find('.overlay')
    overlay.click_button 'New Message Card'
    new overlay
  end

  def subject
    find('main > h1').text
  end

  def subject=(new_text)
    fill_in 'task-title-field', with: new_text
  end

  def body
    find('#task-body').text
  end

  def body=(new_text)
    fill_in 'task-body', with: new_text
  end

  def create(params)
    self.subject = params[:subject]
    self.body = params[:body]
    find('a', text: 'CREATE CARD').click
  end

end
