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

  def edit_submission short_title
    click_on short_title
    EditSubmissionPage.new
  end
end
