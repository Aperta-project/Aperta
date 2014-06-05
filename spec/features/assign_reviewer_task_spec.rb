require 'spec_helper'

feature "Assigns Reviewer", js: true do
  let(:journal) { FactoryGirl.create(:journal) }

  let(:editor) { create :user }

  let!(:albert) { create :user }

  let!(:neil) { create :user }

  let!(:paper) do
    FactoryGirl.create :paper, :with_tasks, user: editor, submitted: true, journal: journal,
      short_title: 'foobar', title: 'Foo Bar'
  end

  before do
    assign_journal_role(journal, editor, :editor)
    assign_journal_role(journal, albert, :reviewer)
    assign_journal_role(journal, neil, :reviewer)
    paper_role = PaperRole.create! paper: paper, user: editor, editor: true

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in editor
  end

  scenario "Editor can assign a reviewer to a paper" do
    dashboard_page = DashboardPage.new
    dashboard_page.view_card 'Assign Reviewers' do |overlay|
      overlay.paper_reviewers = [albert.full_name, neil.full_name]
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end
  end
end
