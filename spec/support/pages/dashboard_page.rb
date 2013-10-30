class DashboardPage < Page
  def self.visit
    self.new.tap { |p| p.navigate }
  end

  def navigate
    visit root_path
    expect(page.current_path).to eq root_path
  end

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
end
