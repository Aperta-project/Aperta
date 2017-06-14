# Represents the main page of the app
class DashboardPage < Page
  include RichTextEditorHelpers

  path :root
  text_assertions :welcome_message, '.welcome-message'
  text_assertions :submitted_paper, '.dashboard-submitted-papers li'

  def fill_in_new_manuscript_fields(paper_title, journal, paper_type)
    page.execute_script('$(".format-input-field").focus()')
    set_rich_text(editor: 'new-paper-title', text: paper_title)
    power_select "#paper-new-journal-select", journal
    power_select "#paper-new-paper-type-select", paper_type
  end

  def submissions
    within("#dashboard-my-submissions") do
      page.all('li').map(&:text)
    end
  end

  def submitted_papers
    within(".dashboard-submitted-papers") do
      page.all('li').map(&:text)
    end
  end

  def has_submission?(submission_name)
    has_css?('.dashboard-paper-title', text: submission_name)
  end

  def has_no_submission?(submission_name)
    has_no_css?('.dashboard-paper-title', text: submission_name)
  end

  def view_submitted_paper(paper)
    title = paper.title || paper.short_title
    click_link title
    wait_for_ajax
    PaperPage.new
  end

  # doesn't wait for elements to appear.
  def has_no_admin_link?
    all('.main-navigation-item', text: 'Admin').empty?
  end

  def admin_link
    find('.main-navigation-item', text: 'Admin')
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

  def expect_paper_to_be_withdrawn(paper)
    row = page.find("tr[data-test-id='dashboard-paper-#{paper.id}']")
    expect(row).to be
    within "tr[data-test-id='dashboard-paper-#{paper.id}']" do
      status = page.find('.status-tag')
      expect(status.text).to match(/withdrawn/i)
    end
  end

  def expect_active_invitations_count(count)
    if count.zero?
      expect(page).not_to have_selector('.invitation-count')
    else
      expect(page).to have_selector('.invitation-count')
      expect(page.find('.invitation-count')).to have_content(count.to_s)
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
      reload
      has_submission?(paper.title)
    end
  end

  def view_invitations
    press_view_invitations_button

    if block_given?
      yield(pending_invitations.map do |invitation|
        PendingInvitationFragment.new(invitation)
      end)
    else
      pending_invitations
    end
  end

  def pending_invitations
    all '.pending-invitation'
  end

  def has_pending_invitations?(count)
    has_css?('.pending-invitation', count: count)
  end

  def has_no_pending_invitations?
    has_no_css? '.pending-invitation'
  end

  def press_view_invitations_button
    click_button 'View invitations'
  end
end
