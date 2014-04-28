class PhaseFragment < PageFragment
  def new_card(**params)
    find('a', text: 'ADD NEW CARD').click
    overlay = session.find('.overlay-container')
    overlay.click_button 'New Task Card'
    adhoc_card = NewAdhocCardOverlay.new overlay
    adhoc_card.title = params[:title]
    adhoc_card.body = params[:body]
    adhoc_card.assignee = params[:assignee].full_name
    adhoc_card.create
  end

  def remove_card(card_name)
    container = find('.card', text: card_name)
    container.hover
    container.find('.remove-card').click
  end

  def card_count
    all('.card').count
  end

  def new_message_card(**params)
    find('a', text: 'ADD NEW CARD').click
    overlay = session.find('.overlay')
    overlay.click_button 'New Message Card'
    message_card = NewMessageCardOverlay.new overlay
    expect(message_card.participants).to include(params[:creator].full_name)
    message_card.participants = params[:participants]
    all_participants = params[:participants] + [params[:creator]]
    expect(message_card.participants).to include(*all_participants.map(&:full_name))
    message_card.subject = params[:subject]
    message_card.body = params[:body]
    message_card.create
  end

  # add a phase AFTER this phase.
  def add_phase
    container = find('.add-column', visible: false)
    container.hover
    container.click
  end

  def remove_phase
    container = find('.column-title')
    container.hover
    remove = find('.remove-icon')
    remove.click
  end

  def rename(new_name)
    field = find('h2')
    field.click
    field.set(new_name)
    expect(self).to have_content(new_name)
    find('.primary-button').click
  end
end
