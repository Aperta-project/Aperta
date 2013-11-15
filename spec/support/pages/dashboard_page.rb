class DashboardPage < Page
  path :root

  def new_submission
    click_on "New submission"
    NewSubmissionPage.new
  end

  def header
    page.find 'header'
  end

  def sign_out
    click_on 'Sign out'
  end

  def submissions
    within("ul.submissions") do
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
    EditSubmissionPage.new
  end

  def view_paper short_title
    within('.submitted') { click_link short_title }
    PaperPage.new
  end

  def visit_admin
    click_on "Admin"
    AdminUsersPage.new
  end
end
