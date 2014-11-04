require 'spec_helper'

feature "Assigns Editor", js: true do
  let(:admin) { FactoryGirl.create(:user, site_admin: true) }
  let(:editor) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, user: admin, submitted: true) }
  let!(:task) { FactoryGirl.create(:paper_editor_task, paper: paper) }

  before do
    assign_journal_role(paper.journal, admin, :editor)
    assign_journal_role(paper.journal, editor, :editor)

    SignInPage.visit.sign_in admin
  end

  scenario "Admin can assign an editor to a paper" do
    dashboard_page = DashboardPage.new
    paper_page = dashboard_page.view_submitted_paper(paper)
    task_manager_page = paper_page.visit_task_manager

    needs_editor_phase = task_manager_page.phase(task.phase.name)
    needs_editor_phase.view_card(task.title) do |overlay|
      expect(overlay).to_not be_completed
      overlay.paper_editor = editor.full_name
      overlay.mark_as_complete
      expect(overlay).to be_completed
      expect(overlay).to have_editor editor
    end
  end
end
