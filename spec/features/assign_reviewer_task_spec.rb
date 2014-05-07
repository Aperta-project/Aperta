require 'spec_helper'

feature "Assigns Reviewer", js: true do
  let(:journal) { FactoryGirl.create(:journal, :with_default_template) }

  let(:editor) do
    create :user,
      journal_roles: [JournalRole.new(journal: journal, editor: true)]
  end

  let!(:albert) do
    create :user,
      journal_roles: [JournalRole.new(journal: journal, reviewer: true)]
  end

  let!(:neil) do
    create :user,
      journal_roles: [JournalRole.new(journal: journal, reviewer: true)]
  end

  let!(:paper) do
    FactoryGirl.create :paper, :with_tasks, user: editor, submitted: true, journal: journal,
      short_title: 'foobar', title: 'Foo Bar'
  end

  before do
    paper_role = PaperRole.create! paper: paper, user: editor, editor: true

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in editor.email
  end

  scenario "Editor can assign a reviewer to a paper" do
    dashboard_page = DashboardPage.visit
    reviewer_card = dashboard_page.view_card 'Assign Reviewers'
    paper_show_page = reviewer_card.view_paper

    paper_show_page.reload

    paper_show_page.view_card 'Assign Reviewers' do |overlay|
      overlay.paper_reviewers = [albert.full_name, neil.full_name]
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    paper_show_page.reload

    paper_show_page.view_card 'Assign Reviewers' do |overlay|
      expect(overlay).to be_completed
      expect(overlay.paper_reviewers).to include(albert.full_name)
      expect(overlay.paper_reviewers).to include(neil.full_name)
    end
  end
end
