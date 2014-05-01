class TaskManagerPage < Page

  path :manage_paper

  def phases
    expect(session).to have_css('.column h2')
    phase_headers = session.all(:css, ".column h2")
    phase_headers.map(&:text)
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
