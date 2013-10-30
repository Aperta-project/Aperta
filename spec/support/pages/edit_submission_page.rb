class EditSubmissionPage < Page
  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end
end
