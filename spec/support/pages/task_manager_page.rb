class TaskManagerPage < Page
  class PhaseFragment < PageFragment
    def new_card(**params)
      find('a', text: 'ADD NEW CARD').click
      overlay = session.find('.overlay-container')
      overlay.click_button 'New Task Card'
      overlay.fill_in 'task_title', with: params[:title]
      overlay.fill_in 'task_body', with: params[:body]
      select_from_chosen params[:assignee].full_name, class: 'select-assignee', visible: false
      overlay.find('a', text: 'CREATE CARD').click
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
  end

  path :manage_paper

  def phases
    expect(page).to have_css('.column h2')
    all('.column h2').map(&:text)
  end

  def phase phase_name
    expect(page).to have_content(phase_name) # use have_content/css/stuff assertion to avoid sleeps.
    PhaseFragment.new(all('.column').detect {|p| p.find('h2').text == phase_name })
  end

  def phase_count
    TaskManagerPage.new.phases.count
  end

  def navigate_to_edit_paper
    within('#control-bar') do
      click_link "Article"
    end
    EditPaperPage.new
  end
end
