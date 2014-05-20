class PhaseFragment < PageFragment
  def new_card(**params)
    find('a', text: 'ADD NEW CARD').click
    new_card = params[:overlay].launch(session)
    new_card.create(params)
  end

  def remove_card(card_name)
    container = find('.card', text: card_name)
    container.hover
    container.find('.remove-card').click
  end

  def card_count
    all('.card').count
  end

  def has_card?(name)
    all('.card').any? { |card| card.has_content? name }
  end

  # add a phase AFTER this phase.
  def add_phase
    container = find('.add-column', visible: false)
    container.hover
    find('.add-column', visible: false).click
    sleep(0.3)
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
