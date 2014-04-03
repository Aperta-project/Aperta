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
    click_on 'Sign out'
  end

  def submissions
    within("#my-submissions") do
      page.all('li').map &:text
    end
  end

  def all_submitted_papers
    within("ul.all_submitted") do
      page.all('li').map &:text
    end
  end

  def submitted_papers
    within(".dashboard-submitted-papers") do
      page.all('li').map &:text
    end
  end

  def edit_submission short_title
    within('.submissions') { click_link short_title }
    EditPaperPage.new
  end

  def view_paper short_title
    within('.dashboard-submitted-papers') { click_link short_title }
    EditPaperPage.new
  end

  def view_flow_manager
    click_link "Flow Manager"
    FlowManagerPage.new
  end

  def view_submitted_paper short_title
    within('.dashboard-submitted-papers') { click_link short_title }
    EditPaperPage.new
  end

  def visit_admin
    click_on "Admin"
    wait_for_turbolinks
    AdminDashboardPage.new
  end
end
