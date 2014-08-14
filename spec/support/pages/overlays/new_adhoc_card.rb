class NewAdhocCardOverlay < CardOverlay

  def self.launch(session)
    overlay = session.find('.overlay-container')
    overlay.click_button 'New Task Card'
    new overlay
  end

  def title
    find('main > div > h1').text
  end

  def title=(new_text)
    find('.inline-edit-h1-icon').click
    fill_in 'title', with: new_text
    find('.button-secondary', text: "SAVE").click
  end

  # def body
  #   find('#task-body').text
  # end
  #
  # def body=(new_text)
  #   fill_in 'task-body', with: new_text
  # end

  def create(params)
    self.title = params[:title]
    # self.body = params[:body]
    # self.assignee = params[:assignee].full_name
    # find('a', text: 'CREATE CARD').click
    self
  end

  # def assignee=(name)
  #   select_from_chosen name, class: 'select-assignee'
  # end

end
