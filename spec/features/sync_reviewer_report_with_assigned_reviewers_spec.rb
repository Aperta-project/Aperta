require 'spec_helper'

feature "Sync Reviewer Report tasks with Assigned Reviewers", js: true do
  let(:admin) { create :user, admin: true }
  let!(:journal) { create :journal }
  let!(:paper) { create :paper, :with_tasks, user: admin, submitted: true, journal: journal }

  let!(:albert) { create :user }

  before do
    assign_journal_role(journal, albert, :reviewer)
    assign_journal_role(journal, admin, :admin)

    page.driver.browser.manage.window.maximize

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  let(:task_manager_page) do
    task_manager_page = TaskManagerPage.visit paper
    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.paper_reviewers = [albert.full_name]
      overlay.mark_as_complete
    end
    task_manager_page
  end

  scenario "Removing a paper reviewer should remove 'ReviewerReport' from the Get Reviews phase" do
    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page.tasks).to_not include('Reviewer Report')
  end

  scenario "Removing a paper reviewer should remove reviewer report task from the renamed phase" do
    get_reviews_phase = task_manager_page.phase 'Get Reviews'
    get_reviews_phase.rename 'Blah Blah Blah'

    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page.tasks).to_not include('Reviewer Report')
  end

  scenario "Removing a paper reviewer should remove reviewer report task from the renamed phase" do
    task_manager_page # perform task manager setup

    reviewer_report_task = paper.tasks.where(type: ReviewerReportTask).first
    new_phase = paper.phases.where("name != ?", "Get Reviews").first
    reviewer_report_task.update_attribute(:phase_id, new_phase.id)

    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page.tasks).to_not include('Reviewer Report')
  end
end
