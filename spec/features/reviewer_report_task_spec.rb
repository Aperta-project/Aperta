require 'spec_helper'

feature "Reviewer Report", js: true do
  let(:journal) { FactoryGirl.create :journal }
  let(:author) { FactoryGirl.create :user }

  let!(:reviewer) do
    FactoryGirl.create :user,
      journal_roles: [JournalRole.new(journal: journal, reviewer: true)]
  end

  before do
    paper = Paper.create! short_title: 'foo-bar',
      title: 'Foo Bar',
      submitted: true,
      journal: journal,
      user: author

    paper_reviewer_task = paper.task_manager.phases.where(name: 'Assign Reviewers').first.tasks.where(type: 'PaperReviewerTask').first
    paper_reviewer_task.reviewer_ids = [reviewer.id.to_s]
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in reviewer.email
  end

  scenario "Reviewer can write a reviewer report" do
    dashboard_page = DashboardPage.visit
    reviewer_report_card = dashboard_page.view_card 'Reviewer Report'
    paper_show_page = reviewer_report_card.view_paper
    sleep(0.5)

    paper_show_page.view_card 'Reviewer Report' do |overlay|
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    paper_show_page.reload

    paper_show_page.view_card 'Reviewer Report' do |overlay|
      expect(overlay).to be_completed
    end
  end
end
