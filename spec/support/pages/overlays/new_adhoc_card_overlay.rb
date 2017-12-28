class NewAdhocCardOverlay < CardOverlay
  text_assertions :card_title, 'main > div > h1'

  def self.launch(session)
    overlay = session.find('.overlay-container')
    overlay.click_button 'New Task Card'
    new overlay
  end

  def title
    find('main > div > h1').text
  end

  def title=(new_text)
    fill_in 'title', with: new_text
    find('.button-secondary', text: "SAVE").click
  end

  def create(params)
    self.title = params[:title]
    self
  end
end
