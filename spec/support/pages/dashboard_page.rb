class DashboardPage < Page
  path :root

  def new_submission
    click_on "Create new submission"
    NewSubmissionPage.new
  end

  def header
    page.find '.dashboard-header'
  end

  def sign_out
    find('a.dropdown-toggle').click
    click_on 'Sign out'
  end

  def submissions
    within("#dashboard-my-submissions") do
      page.all('li').map &:text
    end
  end

  def submitted_papers
    within(".dashboard-submitted-papers") do
      page.all('li').map &:text
    end
  end

  def view_submitted_paper short_title
    within('.dashboard-submitted-papers') { click_link short_title }
    EditPaperPage.new
  end

  def view_flow_manager
    flow_manager_link.click
    FlowManagerPage.new
  end

  def flow_manager_link
    find('.nav-bar-item a', text: "Flow Manager")
  end

  #doesn't wait for elements to appear.
  def has_no_admin_link?
    all('.nav-bar-item a', text: 'Admin').empty?
  end

  def admin_link
    find('.nav-bar-item a', text: "Admin")
  end

  def visit_admin
    admin_link.click
    AdminDashboardPage.new
  end
end
