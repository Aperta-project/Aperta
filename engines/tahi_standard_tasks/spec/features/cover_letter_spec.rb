require 'rails_helper'

feature 'Cover Letter Task', js: true do
  let(:creator) { FactoryGirl.create :user }
  let!(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: creator)
  end
  let!(:task) do
    FactoryGirl.create(:cover_letter_task,
                       paper: paper)
  end

  context 'As creator' do
    before do
      login_as(creator, scope: :user)
      visit "/papers/#{paper.id}"
    end

    let!(:overlay) { Page.view_task_overlay(paper, task) }

    scenario 'I can upload an attachment' do
      find('.fileinput-button').click
      overlay.upload_file(
        element_id: 'file',
        file_name: 'about_turtles.docx',
        sentinel: proc { QuestionAttachment.count }
      )
      within('.attachment-item') do
        expect(page).to have_css('.file-link', text: 'about_turtles.docx')
      end
    end

    scenario 'I can enter freetext' do
      text = 'Here is my cover letter.'
      page.execute_script("tinymce.editors[0].setContent('#{text}')")
      wait_for_ajax
      contents = page.evaluate_script("tinymce.editors[0].getContent()")
      expect(contents).to eq("<p>#{text}</p>")
    end
  end
end
