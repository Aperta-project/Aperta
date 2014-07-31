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
    element.all('.card').count
  end

  def has_card?(name)
    element.all('.card').any? { |card| card.has_content? name }
  end

  def has_remove_icon?
    # I wasn't able to do this using just Capybara. For some reason, the root
    # element never saw the edit or remove icon DOM, even though it's there
    # when you `puts page.html`
    phase_name = element.find('h2').text
    js = "$(_.find($('.column'), function(e) { return $(e).find('h2').text() == '#{phase_name}'; })).find('.remove-icon').size()"
    1 == element.session.evaluate_script(js)
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
    synchronize_content!(new_name)
    find('.column-header-update-save').click
  end
end
