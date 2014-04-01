require 'spec_helper'


feature "Reviewer Report", js: true do
  let(:journal) { Journal.create! }

  let!(:reviewer) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universitat Zurich',
      journal_roles: [JournalRole.new(journal: journal, reviewer: true)]
  end

  before do
    author = User.create! username: 'brain',
      first_name: 'Brain',
      last_name: 'Mouse',
      email: 'brain@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Animaniacs'

    paper = Paper.create! short_title: 'foo-bar',
      title: 'Foo Bar',
      submitted: true,
      journal: journal,
      user: author

    paper_reviewer_task = paper.task_manager.phases.where(name: 'Assign Reviewers').first.tasks.where(type: 'StandardTasks::PaperReviewerTask').first
    paper_reviewer_task.paper_roles = [reviewer.id.to_s]

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in reviewer.email
  end

  scenario "Reviewer can write a reviewer report" do
    dashboard_page = DashboardPage.visit
    reviewer_report_card = dashboard_page.view_card 'Reviewer Report'
    paper_show_page = reviewer_report_card.view_paper

    paper_show_page.view_card 'Reviewer Report' do |overlay|
      # overlay.report = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas congue massa sit amet lacus volutpat pharetra. Quisque lobortis eu risus sit amet'
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    paper_show_page.reload

    paper_show_page.view_card 'Reviewer Report' do |overlay|
      expect(overlay).to be_completed
      # expect(overlay.report).to eq('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas congue massa sit amet lacus volutpat pharetra. Quisque lobortis eu risus sit amet')
    end
  end
end
