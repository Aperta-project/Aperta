require "rails_helper"

feature "session invalidation", js: true do
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_creator,
      :submitted_lite,
      journal: journal,
      uses_research_article_reviewer_report: false
    )
  end
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }
  let(:paper_page) { PaperPage.new }
  let!(:reviewer) { create :user }
  let!(:inviter) { create :user }
  let!(:reviewer_report_task) do
    ReviewerReportTaskCreator.new(
      originating_task: task,
      assignee_id: reviewer.id
    ).process
  end
  let!(:invitation_no_feedback) do
    FactoryGirl.create(
      :invitation,
      :accepted,
      accepted_at: DateTime.now.utc,
      task: reviewer_report_task,
      invitee: reviewer,
      inviter: inviter
    )
  end

  before do
    assign_reviewer_role paper, reviewer
    ReviewerReport.update_report_status(paper: paper, reviewer: reviewer)
    login_as(reviewer, scope: :user)
    Page.view_paper paper
  end

  context "editing a field with an invalid CSRF token" do
    scenario "the user is logged out and returned to the login screen" do
      ident = "front_matter_reviewer_report--competing_interests"
      t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)
      # Mess up the CSRF token
      execute_script <<-JS
        $("head meta[name='csrf-token']").attr("content", "bad token")
      JS
      t.fill_in_fields(ident => "Oops, this is the wrong value")
      # Verify that we're looking at the login screen
      find("h1", text: "Welcome to Aperta")
    end
  end
end
