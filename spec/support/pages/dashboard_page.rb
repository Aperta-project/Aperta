class DashboardPage < Page
  path :root
  text_assertions :welcome_message, '.welcome-message'
  text_assertions :submitted_paper, '.dashboard-submitted-papers li'

  def new_submission
    click_on "Create New Submission"
    NewSubmissionPage.new
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

  def has_submission?(submission_name)
    has_css?('.dashboard-paper-title', text: submission_name)
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

  def active_invitation_count
    invitation_count = all '.invitation-count'
    invitation_count.empty? ? 0 : invitation_count.first.text[/\d+/].to_i
  end

  def view_invitations
    click_button 'View invitations'
    yield(all('.pending-invitation').map do |invitation|
      PendingInvitationFragment.new invitation
    end)
  end
end
