class TaskManagerPage < Page
  path :manage_paper

  def phases
    all('.phase h2').map(&:text)
  end

  def navigate_to_edit_paper
    within('#control-bar') do
      click_link "Article"
    end
    EditSubmissionPage.new
  end
end
