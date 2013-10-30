class EditSubmissionPage < Page
  path :edit_paper

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end
end
