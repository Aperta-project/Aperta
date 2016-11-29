require 'rails_helper'

feature 'Reviewer filling out their front matter article reviewer report', js: true do
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_creator,
      :submitted_lite,
      journal: journal,
      uses_research_article_reviewer_report: false)
  end
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:paper_page){ PaperPage.new }
  let!(:reviewer) { create :user }
  let!(:reviewer_report_task) do
    ReviewerReportTaskCreator.new(
      originating_task: task,
      assignee_id: reviewer.id
    ).process
  end

  before do
    assign_reviewer_role paper, reviewer

    login_as(reviewer, scope: :user)
    visit "/"
    visit "/papers/#{paper.id}"
  end

  scenario "A paper's creator cannot access the Reviewer Report" do
    ensure_user_does_not_have_access_to_task(
      user: paper.creator,
      task: reviewer_report_task
    )
  end

  scenario 'A reviewer can fill out their own Reviewer Report, submit it, and see a readonly view of their responses' do
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)
    t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'I have no competing interests with this work.'
    t.submit_report
    t.confirm_submit_report

    expect(page).to have_selector(".answer-text", text: 'I have no competing interests with this work.')
  end

  scenario 'A reviewer can see their previous rounds of review' do
    # Revision 0
    visit "/papers/#{paper.id}"
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)
    t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 0'

    # no history yet, since we only have the current round of review
    t.ensure_no_review_history

    # Revision 1
    register_paper_decision(paper, "minor_revision")
    paper.submit! paper.creator

    visit "/papers/#{paper.id}"
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)
    t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 1'

    t.ensure_review_history(
      title: 'Revision 0', answers: ['answer for round 0']
    )

    # Revision 2
    register_paper_decision(paper, "minor_revision")
    paper.submit! paper.creator

    visit "/papers/#{paper.id}"
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)
    t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 2'

    t.ensure_review_history(
      {title: 'Revision 0', answers: ['answer for round 0']},
      {title: 'Revision 1', answers: ['answer for round 1']}
    )

    # Revision 3 (we won't answer, just look at previous rounds)
    register_paper_decision(paper, "minor_revision")
    paper.submit! paper.creator

    visit "/papers/#{paper.id}"
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

    t.ensure_review_history(
      {title: 'Revision 0', answers: ['answer for round 0']},
      {title: 'Revision 1', answers: ['answer for round 1']},
      {title: 'Revision 2', answers: ['answer for round 2']}
    )
  end
end
