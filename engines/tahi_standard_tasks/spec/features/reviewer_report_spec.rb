require 'rails_helper'

feature "Reviewer filling out their reviewer report", js: true do
  pending "The reviewer still needs to be assigned to the report task"
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper_with_phases, journal: journal }
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }
  let!(:reviewer1) { create :user }

  before do
    assign_journal_role journal, editor, :editor
    assign_handling_editor_role paper, editor
    assign_reviewer_role paper, reviewer1
    task.add_participant(editor)
    ReviewerReportTaskCreator.new(
      originating_task: task,
      assignee_id: reviewer1.id).process

    login_as(reviewer1, scope: :user)
    visit "/"
    visit "/papers/#{paper.id}"
  end

  scenario "A reviewer can fill out their own Reviewer Report, submit it, and see a readonly view of their responses" do
    paper_page = PaperPage.new

    t = paper_page.view_task("Review by #{reviewer1.full_name}", ReviewerReportTask)
    t.fill_in_report "reviewer_report--competing_interests" => "I have no competing interests with this work."
    t.submit_report
    t.confirm_submit_report

    expect(page).to have_selector(".answer-text", text: "I have no competing interests with this work.")
  end

  scenario "A review can see their previous rounds of review" do
    reviewer_report_task = TahiStandardTasks::ReviewerReportTask.last
    paper_page = PaperPage.new

    # Revision 0
    visit "/papers/#{paper.id}"
    t = paper_page.view_task("Review by #{reviewer1.full_name}", ReviewerReportTask)
    t.fill_in_report "reviewer_report--competing_interests" => "answer for round 0"

    # no history yet, since we only have the current round of review
    t.ensure_no_review_history

    # Revision 1
    decision_revision_1 = FactoryGirl.create(:decision, paper: paper)
    reviewer_report_task.update!(decision: decision_revision_1)
    visit "/papers/#{paper.id}"
    t = paper_page.view_task("Review by #{reviewer1.full_name}", ReviewerReportTask)
    t.fill_in_report "reviewer_report--competing_interests" => "answer for round 1"

    t.ensure_review_history(
      title: "Revision 0", answers: ["answer for round 0"]
    )

    # Revision 2
    decision_revision_2 = FactoryGirl.create(:decision, paper: paper)
    reviewer_report_task.update!(decision: decision_revision_2)
    visit "/papers/#{paper.id}"
    t = paper_page.view_task("Review by #{reviewer1.full_name}", ReviewerReportTask)
    t.fill_in_report "reviewer_report--competing_interests" => "answer for round 2"

    t.ensure_review_history(
      {title: "Revision 0", answers: ["answer for round 0"]},
      {title: "Revision 1", answers: ["answer for round 1"]}
    )

    # Revision 3 (we won't answer, just look at previous rounds)
    decision_revision_3 = FactoryGirl.create(:decision, paper: paper)
    reviewer_report_task.update!(decision: decision_revision_3)
    visit "/papers/#{paper.id}"
    t = paper_page.view_task("Review by #{reviewer1.full_name}", ReviewerReportTask)

    t.ensure_review_history(
      {title: "Revision 0", answers: ["answer for round 0"]},
      {title: "Revision 1", answers: ["answer for round 1"]},
      {title: "Revision 2", answers: ["answer for round 2"]}
    )
  end
end
