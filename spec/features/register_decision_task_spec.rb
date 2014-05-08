require 'spec_helper'

feature "Register Decision", js: true do

  let(:journal) { FactoryGirl.create :journal, :with_default_template }

  let!(:editor) do
    create :user,
      journal_roles: [JournalRole.new(journal: journal, editor: true)]
  end

  let!(:paper) do
    FactoryGirl.create(:paper, :with_tasks, user: editor, submitted: true, journal: journal)
  end

  before do
    paper_role = PaperRole.create! user: editor, paper: paper, editor: true
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in editor
  end

  scenario "Editor registers a decision on the paper" do
    dashboard_page = DashboardPage.visit
    register_decision_card = dashboard_page.view_card 'Register Decision'
    paper_show_page = register_decision_card.view_paper
    paper_show_page.reload

    paper_show_page.view_card 'Register Decision' do |overlay|
      overlay.register_decision = "Accepted"
      overlay.decision_letter = "Accepting this because I can"
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    paper_show_page.reload

    paper_show_page.view_card 'Register Decision' do |overlay|
      expect(overlay).to be_completed
      expect(overlay).to be_accepted
      expect(overlay.decision_letter).to eq("Accepting this because I can")
    end
  end
end
