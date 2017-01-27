require 'rails_helper'

feature 'Reviewer filling out their front matter article reviewer report', js: true do
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
  let!(:reviewer_report_task) do
    create_reviewer_report_task
  end

  def create_reviewer_report_task
    ReviewerReportTaskCreator.new(
      originating_task: task,
      assignee_id: reviewer.id
    ).process
  end

  before do
    assign_reviewer_role paper, reviewer

    login_as(reviewer, scope: :user)
    visit "/"
    Page.view_paper paper
  end

  scenario "A paper's creator cannot access the Reviewer Report" do
    ensure_user_does_not_have_access_to_task(
      user: paper.creator,
      task: reviewer_report_task
    )
  end

  scenario 'A reviewer can fill out their own Reviewer Report, submit it, and see a readonly view of their responses' do
    ident = 'front_matter_reviewer_report--competing_interests'
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)
    answers = NestedQuestion.where(ident: ident).first.nested_question_answers
    sentinel_proc = -> { answers.count }

    # Recreating the error in APERTA-8647
    t.wait_for_sentinel(sentinel_proc) do
      t.fill_in_report ident => 'Oops, this is the wrong value'
    end
    t.wait_for_sentinel(sentinel_proc) do
      t.fill_in_report ident => ''
    end
    no_compete = 'I have no competing interests with this work.'
    t.wait_for_sentinel(sentinel_proc) do
      t.fill_in_report ident => no_compete
    end
    t.submit_report
    t.confirm_submit_report
    expect(page).to have_selector(".answer-text", text: no_compete)
    expect(answers.count).to eq(1)
    expect(answers.reload.first.value).to eq('I have no competing interests with this work.')
  end

  scenario 'A reviewer can see their previous rounds of review' do
    # Revision 0
    Page.view_paper paper
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)
    t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 0'

    # no history yet, since we only have the current round of review
    t.ensure_no_review_history

    t.submit_report
    t.confirm_submit_report

    # Revision 1
    register_paper_decision(paper, "minor_revision")
    paper.submit! paper.creator

    # Create new report with our reviewer
    create_reviewer_report_task

    Page.view_paper paper
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

    t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 1'

    t.submit_report
    t.confirm_submit_report

    t.ensure_review_history(
      title: 'v0.0 Completed', answers: ['answer for round 0']
    )

    # Revision 2
    register_paper_decision(paper, "minor_revision")
    paper.submit! paper.creator

    # Create new report with our reviewer
    create_reviewer_report_task

    Page.view_paper paper
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)
    t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 2'

    t.ensure_review_history(
      { title: 'v0.0 Completed', answers: ['answer for round 0'] },
      { title: 'v1.0 Completed', answers: ['answer for round 1'] }
    )

    # Revision 3 (we won't answer, just look at previous rounds)
    register_paper_decision(paper, "minor_revision")
    paper.submit! paper.creator

    Page.view_paper paper
    t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

    t.ensure_review_history(
      { title: 'v0.0 Completed', answers: ['answer for round 0'] },
      { title: 'v1.0 Completed', answers: ['answer for round 1'] },
      { title: 'v2.0 Completed', answers: ['answer for round 2'] }
    )
  end
end
