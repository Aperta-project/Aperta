class NewMessageCardOverlay < CardOverlay

  def self.launch(session)
    overlay = session.find('.overlay')
    overlay.click_button 'New Message Card'
    new overlay
  end

  def participants=(users)
    users.map(&:full_name).each { |name| select_from_chosen name, class: 'participant-select' }
  end

  def participants
    expect(page).to have_css '.participants'
    all('.participant .user-thumbnail').map { |e| e["alt"] }
  end

  def subject
    find('main > h1').text
  end

  def subject=(new_text)
    fill_in 'task-title-field', with: new_text
  end

  def body
    find('#task_body').text
  end

  def body=(new_text)
    fill_in 'task_body', with: new_text
  end

  def create(params)
    self.participants = params[:participants]
    expect(participants).to include(params[:creator].full_name)
    all_participants = params[:participants] + [params[:creator]]
    expect(participants).to include(*all_participants.map(&:full_name))
    self.subject = params[:subject]
    self.body = params[:body]
    find('a', text: 'CREATE CARD').click
  end

end
