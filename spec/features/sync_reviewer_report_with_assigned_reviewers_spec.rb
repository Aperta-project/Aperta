require 'spec_helper'

feature "Sync Reviewer Report tasks with Assigned Reviewers", js: true do
  let(:admin) { create :user, admin: true }
  let!(:journal) { create :journal, :with_default_template }
  let!(:paper) { create :paper, :with_tasks, user: admin, submitted: true, journal: journal }

  let!(:albert) do
    create :user,
           journal_roles: [JournalRole.new(journal: journal, reviewer: true)]
  end

  before do
    JournalRole.create! admin: true, journal: journal, user: admin

    page.driver.browser.manage.window.maximize

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  scenario "Removing a paper reviewer should remove 'ReviewerReport' from the Get Reviews phase" do
    task_manager_page = TaskManagerPage.visit paper
    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.paper_reviewers = [albert.full_name]
      overlay.mark_as_complete
    end

    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page.tasks).to_not include('Reviewer Report')
  end

  scenario "Removing a paper reviewer should remove reviewer report task from the renamed phase" do
    task_manager_page = TaskManagerPage.visit paper
    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.paper_reviewers = [albert.full_name]
      overlay.mark_as_complete
    end

    get_reviews_phase = task_manager_page.phase 'Get Reviews'
    get_reviews_phase.rename 'Blah Blah Blah'

    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page.tasks).to_not include('Reviewer Report')
  end

  scenario "Removing a paper reviewer should remove reviewer report task from the renamed phase" do
    task_manager_page = TaskManagerPage.visit paper
    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.paper_reviewers = [albert.full_name]
      overlay.mark_as_complete
    end

    reviewer_report_task = paper.tasks.where(type: ReviewerReportTask).first
    new_phase = paper.phases.where("name != ?", "Get Reviews").first
    reviewer_report_task.update_attribute(:phase_id, new_phase.id)

    task_manager_page.view_card 'Assign Reviewers' do |overlay|
      overlay.remove_all_paper_reviewers!
    end

    expect(task_manager_page.tasks).to_not include('Reviewer Report')
  end
end
