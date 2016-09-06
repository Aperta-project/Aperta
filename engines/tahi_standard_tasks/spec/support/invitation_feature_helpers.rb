module InvitationFeatureHelpers
  include SidekiqHelperMethods

  def invite_new_reviewer_for_paper(email, paper)
    dashboard_page = DashboardPage.new
    dashboard_page.view_submitted_paper paper
    overlay = Page.view_task_overlay(paper, task)
    overlay.invite_new_reviewer email
    expect(overlay).to have_reviewers email
    overlay.dismiss
  end

  def ensure_email_got_sent_to(email)
    expect do
      process_sidekiq_jobs
    end.to change(ActionMailer::Base.deliveries, :count)
    expect(find_email(email)).to_not be_nil
  end

  def sign_up_as(email)
    SignInPage.visit
    click_on "Sign up"
    SignUpPage.new.sign_up_as(email: email)
  end
end
