class PhaseFragment < PageFragment
  text_assertions :card, '.card'

  def new_card(**params)
    find('a', text: 'ADD NEW CARD').click
    new_card = params[:overlay].launch(session)
    new_card.create(params)
  end

  def remove_card(card_name)
    container = find('.card', text: card_name)
    container.hover
    container.find('.card-remove').click
  end

  def card_count
    find_all('.card').count
  end

  def has_remove_icon?
    has_css? '.remove-icon', visible: false
  end

  def has_no_remove_icon?
    has_no_css? '.remove-icon', visible: false
  end

  # add a phase AFTER this phase.
  def add_phase
    container = find('.add-column', visible: false)
    container.hover
    find('.add-column', visible: false).click
  end

  def remove_phase
    retry_stale_element do
      container = find('.column-title')
      container.hover
      remove = find('.remove-icon')
      remove.click
    end
  end

  def rename(new_name)
    field = find('h2')
    field.click
    reversed_name = new_name.reverse
    field.set(reversed_name)
    synchronize_content!(reversed_name)
    find('.column-header-update-save').click
  end
end
