require 'spec_helper'

feature "Assigns Editor", js: true, solr: true do
  let(:admin) { create :user, site_admin: true }
  let!(:editor) { create :user }
  let(:journal) { FactoryGirl.create :journal }
  let!(:paper) do
    FactoryGirl.create :paper, :with_tasks, user: admin, submitted: true, journal: journal,
      short_title: 'foobar', title: 'Foo Bar'
  end

  before do
    assign_journal_role(journal, admin, :editor)
    assign_journal_role(journal, editor, :editor)

    SignInPage.visit.sign_in admin
  end

  scenario "Admin can assign an editor to a paper" do
    dashboard_page = DashboardPage.new
    paper_page = dashboard_page.view_submitted_paper paper
    task_manager_page = paper_page.visit_task_manager

    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Editor' do |overlay|
      expect(overlay).to_not be_completed
      overlay.paper_editor = editor
      overlay.mark_as_complete
      expect(overlay).to be_completed
      expect(overlay).to have_editor editor
    end
  end
end
