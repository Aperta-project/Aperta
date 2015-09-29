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
    PaperPage.new
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

  def total_active_paper_count
    find('.welcome-message').text.match(/You have (\d+)/)[1].to_i
  end

  def toggle_active_papers_heading
    find('.active-papers').click
  end

  def toggle_inactive_papers_heading
    find('.inactive-papers').click
  end

  def manuscript_list_visible?
    first('.dashboard-submitted-papers').present?
  end

  def load_more_papers
    load_more_papers_button.click
  end

  def load_more_papers_button
    find '.load-more-papers'
  end

  def expect_active_invitations_count(count)
    if count == 0
      expect(page).not_to have_selector('.invitation-count')
    else
      expect(page).to have_selector('.invitation-count')
      expect(page.find('.invitation-count')).to have_content("#{count}")
    end
  end

  def accept_invitation_for_paper(paper)
    tap do
      view_invitations do |invitations|
        expect(invitations.count).to eq 1
        invitation = invitations.first
        expect(invitation.text).to match(paper.title)
        invitation.accept
      end
      process_sidekiq_jobs
    end
  end

  def view_invitations &block
    click_button 'View invitations'

    if block_given?
      block.call(pending_invitations.map do |invitation|
        PendingInvitationFragment.new invitation
      end)
    else
      pending_invitations
    end
  end

  def pending_invitations
    all '.pending-invitation'
  end
end
