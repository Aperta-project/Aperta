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
    find('h1 .inline-edit-icon').click
    fill_in 'title', with: new_text
    find('.button-secondary', text: "SAVE").click
  end

  def create(params)
    self.title = params[:title]
    self
  end

  def create_email(params)
    find('.adhoc-content-toolbar .glyphicon-plus').click
    find(".adhoc-content-toolbar .adhoc-toolbar-item--email").click
    expect(page).to have_css('.inline-edit-form')
    fill_in 'Enter a subject', with: params[:subject]
    session.execute_script(
    <<-SCRIPT
    $('.inline-edit-form div[contenteditable]')
      .html("#{params[:body]}")
      .trigger('keyup')
    SCRIPT
    )
  end
end
