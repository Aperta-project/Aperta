require 'rails_helper'

feature "Dashboard", js: true do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt }
  let(:inactive_paper_count) { 0 }
  let(:active_paper_count) { 1 }
  let!(:papers) do
    Array.new(inactive_paper_count) do |number|
      FactoryGirl.create :paper, :withdrawn_lite, :with_tasks, journal: journal, creator: user,
                                                               title: "Inactive Paper (#{number + 1})"
    end
    Array.new(active_paper_count) do |number|
      FactoryGirl.create :paper, :active, :with_tasks, journal: journal, creator: user,
                                                       title: "Active Paper (#{number + 1})"
    end
  end
  let(:dashboard) { DashboardPage.new }

  feature "displaying papers list" do
    let(:active_paper_count) { 2 }
    let(:inactive_paper_count) { 1 }
    let(:paper) { papers.first }

    scenario "shows how many active and inactive papers" do
      login_as(user, scope: :user)
      visit "/"

      expect(Paper.where(journal: journal).count).to eq(active_paper_count + inactive_paper_count)
      expect(dashboard.total_active_paper_count).to eq(active_paper_count)
    end

    scenario "can hide active and inactive papers" do
      login_as(user, scope: :user)
      visit "/"
      expect(dashboard.total_active_paper_count).to eq active_paper_count

      expect(page).to have_content("Active Manuscripts (2)")
      expect(page).to have_content("Inactive Manuscript (1)")
      dashboard.toggle_active_papers_heading
      expect(page).to_not have_content("Active Paper (1)")
      dashboard.toggle_inactive_papers_heading
      expect(page).to_not have_content("Inactive Paper (1)")
      expect(dashboard.manuscript_list_visible?).to eq false
    end
  end

  feature "displaying roles and state" do
    let(:active_paper_count) { 1 }
    let(:inactive_paper_count) { 1 }
    let(:paper) { papers.first }

    scenario "shows how many active and inactive papers" do
      login_as(user, scope: :user)
      visit "/"

      within('.active-paper-table-row') { expect(page).to have_content("Author") }
      within('.active-paper-table-row') { expect(page).to have_content("DRAFT") }
      within('.inactive-paper-table-row') { expect(page).to have_content("Author") }
      within('.inactive-paper-table-row') { expect(page).to have_content("WITHDRAWN") }
    end
  end

  feature "displaying review due dates" do
    let(:paper_reviewer_task) { FactoryGirl.create :paper_reviewer_task, paper: paper }
    let(:paper) do
      FactoryGirl.create(
        :paper_with_phases,
        :with_creator,
        :submitted_lite,
        journal: journal
      )
    end
    let(:papers) { [paper] }
    let(:invitation) do
      FactoryGirl.create(
        :invitation,
        :accepted,
        accepted_at: DateTime.now.utc,
        invitee: user,
        task: paper_reviewer_task,
        decision: paper.draft_decision
      )
    end

    before do
      FactoryGirl.create :feature_flag, name: "REVIEW_DUE_DATE"
      FactoryGirl.create :feature_flag, name: "REVIEW_DUE_AT"

      paper.draft_decision.invitations << invitation
      ReviewerReportTaskCreator.new(
        originating_task: paper_reviewer_task,
        assignee_id: user.id
      ).process

      login_as(user, scope: :user)
    end

    scenario "shows review due date" do
      visit "/"
      within('.active-paper-table-row') { expect(page).to have_content("Your review is due") }
    end

    scenario "shows original due date" do
      report = ReviewerReport.for_invitation(invitation)
      report.set_due_datetime(length_of_time: 100.days)

      visit "/"
      within('.active-paper-table-row') { expect(page).to have_content("Originally due") }
    end
  end

  feature "displaying journal name" do
    let(:active_paper_count) { 1 }
    let(:paper) { papers.first }

    scenario "shows journal name with manuscript" do
      login_as(user, scope: :user)
      visit "/"

      within('.dashboard-journal-name') { expect(page).to have_content(journal.name) }
    end
  end

  feature "displaying invitations" do
    let(:active_paper_count) { 1 }
    let(:paper) { FactoryGirl.create :paper_with_phases, :submitted_lite }
    let(:task) do
      FactoryGirl.create(
        :paper_editor_task,
        paper: paper,
        phase: paper.phases.first
      )
    end

    before do
      FactoryGirl.create_pair(:invitation, :invited, task: task, invitee: user)

      # seed the Upload Manuscript card so that it can be created after a decision has been registered
      ctt = CardTaskType.find_by(task_class: "TahiStandardTasks::UploadManuscriptTask")
      FactoryGirl.create(:card, :versioned, card_task_type: ctt)
    end

    scenario "only displays invitations from latest revision cycle" do
      login_as(user, scope: :user)
      visit "/"

      dashboard.expect_active_invitations_count(2)
      paper.draft_decision.update(verdict: 'major_revision')
      paper.draft_decision.register! FactoryGirl.create(:register_decision_task)
      paper.submit! user
      dashboard.reload

      dashboard.expect_active_invitations_count(0)
      FactoryGirl.create(:invitation, :invited, task: task, invitee: user)
      dashboard.reload

      dashboard.expect_active_invitations_count(1)
      dashboard.view_invitations do |invitations|
        expect(invitations.count).to eq 1
        invitations.first.reject
        expect(dashboard).to have_no_pending_invitations
      end
      dashboard.reload

      expect(dashboard).to have_no_pending_invitations
    end
  end
end
