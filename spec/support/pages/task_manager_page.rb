class TaskManagerPage < Page

  path :manage_paper

  def phases
    begin
      expect(page).to have_css('.column h2')
      all('.column h2').map(&:text)
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      sleep 1
      retry
    end
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
