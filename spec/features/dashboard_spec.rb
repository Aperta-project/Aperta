require 'rails_helper'

feature "Dashboard", js: true do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:inactive_paper_count) { 0 }
  let(:active_paper_count) { 1 }
  let!(:papers) do
    inactive_paper_count.times.map do |number|
      FactoryGirl.create :paper, :inactive, :with_tasks, journal: journal, creator: user,
                         title: "Inactive Paper (#{number + 1})"
    end
    active_paper_count.times.map do |number|
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

        expect(Paper.count).to eq(3)
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

  feature "displaying old_roles and state" do
    let(:active_paper_count) { 1 }
    let(:inactive_paper_count) { 1 }
    let(:paper) { papers.first }

    scenario "shows how many active and inactive papers" do
      login_as(user, scope: :user)
      visit "/"

      within('.active-paper-table-row') { expect(page).to have_content("Author")}
      within('.active-paper-table-row') { expect(page).to have_content("DRAFT")}
      within('.inactive-paper-table-row') { expect(page).to have_content("Author")}
      within('.inactive-paper-table-row') { expect(page).to have_content("WITHDRAWN")}
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
        expect(dashboard.pending_invitations.count).to eq 0
      end
      dashboard.reload

      expect(dashboard.pending_invitations.count).to eq 0
    end
  end

end
