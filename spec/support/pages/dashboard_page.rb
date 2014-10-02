class DashboardPage < Page
  path :root
  text_assertions :welcome_message, '.welcome-message'

  def new_submission
    click_on "Create New Submission"
    NewSubmissionPage.new
  end

  def sign_out
    find('.navigation-toggle').click
    find('a.navigation-item', text: 'SIGN OUT').click
    
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

  def view_submitted_paper paper
    title = paper.title || paper.short_title
    within('.dashboard-submitted-papers') { click_link title }
    EditPaperPage.new
  end

  def view_flow_manager
    flow_manager_link.click
    FlowManagerPage.new
  end

  def flow_manager_link
    find('.navigation-toggle').click
    find('.navigation-item', text: "FLOW MANAGER")
  end

  #doesn't wait for elements to appear.
  def has_no_admin_link?
    find('.navigation-toggle').click
    all('.navigation-item', text: 'ADMIN').empty?
  end

  def admin_link
    find('.navigation-toggle').click
    find('.navigation-item', text: "ADMIN")
  end

  def visit_admin
    admin_link.click
    AdminDashboardPage.new
  end

  def paper_count
    all('.dashboard-paper-title').count
  end

  def total_paper_count
    find('.welcome-message').text.match(/You have (\d+)/)[1].to_i
  end

  def load_more_papers
    load_more_papers_button.click
  end

  def load_more_papers_button
    find '.load-more-papers'
  end
end
