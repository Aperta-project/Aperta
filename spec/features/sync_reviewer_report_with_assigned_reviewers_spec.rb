require 'spec_helper'

feature "Sync Reviewer Report tasks with Assigned Reviewers", js: true do
  let(:admin) { create :user, admin: true }
  let!(:journal) { create :journal }
  let!(:paper) { create :paper, :with_tasks, user: admin, submitted: true, journal: journal }

  let!(:albert) { create :user }

  before do
    assign_journal_role(journal, albert, :reviewer)
    assign_journal_role(journal, admin, :admin)
    paper.tasks.find_by(type: "StandardTasks::PaperReviewerTask").reviewer_ids = [albert.id]

    page.driver.browser.manage.window.maximize

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  let(:task_manager_page) do
    TaskManagerPage.visit paper
  end

  scenario "Removing a paper reviewer should remove 'ReviewerReport' from the Get Reviews phase" do
    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page).to have_no_task('Reviewer Report')
  end

  scenario "Removing a paper reviewer should remove reviewer report task from the renamed phase" do
    get_reviews_phase = task_manager_page.phase 'Get Reviews'
    get_reviews_phase.rename 'Blah Blah Blah'

    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page).to have_no_task('Reviewer Report')
  end

  scenario "Removing a paper reviewer should remove reviewer report task from the renamed phase" do
    expect(task_manager_page).to have_task('Reviewer Report')

    reviewer_report_task = paper.tasks.where(type: StandardTasks::ReviewerReportTask).first
    new_phase = paper.phases.where("name != ?", "Get Reviews").first
    reviewer_report_task.update_attribute(:phase_id, new_phase.id)

    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page).to have_no_task('Reviewer Report')
  end
end
