require 'rails_helper'

feature 'Invite Editor', js: true do
  let(:admin) { FactoryGirl.create(:user) }
  let(:editor) { FactoryGirl.create(:user) }
  let(:creator) { FactoryGirl.create(:user) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: creator)
  end
  let!(:task) do
    FactoryGirl.create(:paper_editor_task, paper: paper)
  end

  before do
    assign_journal_role(paper.journal, admin, :admin)
    assign_journal_role(paper.journal, editor, :editor)

    login_as(admin, scope: :user)
    visit "/papers/#{paper.id}/tasks/#{task.id}"
  end

  scenario 'Editor can be invited be an Academic Editor on a paper', selenium: true do
    overlay = InviteEditorOverlay.new
    expect(overlay).to_not be_completed
    overlay.paper_editors = [editor]
    overlay.mark_as_complete
    expect(overlay).to be_completed
    expect(overlay).to have_editor editor
    overlay.sign_out

    login_as(editor)
    visit '/'

    dashboard = DashboardPage.new
    dashboard.view_invitations do |invitations|
      expect(invitations.count).to eq 1
      invitations.first.accept
      wait_for_ajax
      expect(dashboard.pending_invitations.count).to eq 0
    end
    dashboard.reload

    within('.active-paper-table-row') do
      expect(page).to have_content('Academic Editor')
    end
  end
end
