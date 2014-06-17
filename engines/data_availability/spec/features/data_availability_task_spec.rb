require 'spec_helper'

feature "Data Availability", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, user: author, journal: journal }

  before do
    paper.phases.last.tasks.create!(type: "DataAvailability::Task")
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "basic checkbox questions" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Data Availability' do |overlay|
      question = overlay.nth_check_question(1)
      expect(question).to_not be_checked
      expect(question).to_not have_content('.dataset')
      question.check
      expect(question.dataset).to be_visible
      question.fill_dataset_field('url', 'http://google.com')
    end

  end
end
