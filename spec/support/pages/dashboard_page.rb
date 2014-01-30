class DashboardPage < Page
  path :root

  def new_submission
    click_on "Create new submission"
    NewSubmissionPage.new
  end

  def header
    page.find '#tahi-container header'
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
    within("ul.submitted") do
      page.all('li').map &:text
    end
  end

  def edit_submission short_title
    within('.submissions') { click_link short_title }
    EditPaperPage.new
  end

  def view_paper short_title
    within('.submitted') { click_link short_title }
    PaperPage.new
  end

  def view_submitted_paper short_title
    within('.all_submitted') { click_link short_title }
    PaperPage.new
  end

  def visit_admin
    click_on "Admin"
    AdminDashboardPage.new
  end

  def register_decision_overlay
    click_on 'Register Decision'
    overlay = RegisterDecisionOverlay.new find('#new-overlay')
    if block_given?
      block.call overlay
      overlay.dismiss
    else
      overlay
    end
  end
end
