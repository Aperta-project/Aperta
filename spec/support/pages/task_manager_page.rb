class TaskManagerPage < Page
  class PhaseFragment < PageFragment
  end

  path :manage_paper

  def phases
    all('.phase h2').map(&:text)
  end

  def phase phase_name
    phase = all('.phase').detect do |p|
      p.find('h2').text == phase_name
    end
    PhaseFragment.new phase
  end

  def navigate_to_edit_paper
    within('#control-bar') do
      click_link "Article"
    end
    EditPaperPage.new
  end
end
