require 'rails_helper'

feature 'Authors card', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let!(:task) do
    FactoryGirl.create(:publishing_related_questions_task, paper: paper)
  end

  before do
    paper.tasks.each { |t| t.participants << author }
  end

  def short_title_selector
    "//div[contains(@class, 'publishing-related-questions-short-title')]" \
      "//div[@contenteditable='true']"
  end

  context 'As an author' do
    scenario 'sets the short title properly', selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"

      edit_paper = PaperPage.new
      edit_paper.view_card('Publishing Related Questions', CardOverlay) do |_|
        content_editable = find(:xpath, short_title_selector)
        # <br> tags are only added when the space key is hit. So we clear the
        # field first then type in known text.
        content_editable.set('T')
        content_editable.send_keys('his is a short title', :tab)
        wait_for_ajax
        paper.reload

        expect(paper.short_title).not_to include('<br')
        expect(paper.short_title).to eq('This is a short title')
      end
    end
  end
end
