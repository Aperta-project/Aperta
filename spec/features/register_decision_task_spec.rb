require 'spec_helper'

feature "Register Decision", js: true do

  let(:journal) { Journal.create! }

  let!(:editor) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universitat Zurich',
      journal_roles: [JournalRole.new(journal: journal, editor: true)]
  end

  before do
    paper = Paper.create! short_title: 'foo-bar',
      title: 'Foo Bar',
      submitted: true,
      journal: journal

    paper_role = PaperRole.create! user: editor, paper: paper, editor: true
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in editor.email
  end

  scenario "Editor registers a decision on the paper" do
    dashboard_page = DashboardPage.visit
    register_decision_card = dashboard_page.view_card 'Register Decision'
    paper_show_page = register_decision_card.view_paper

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
