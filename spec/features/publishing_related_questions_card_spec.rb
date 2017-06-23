require 'rails_helper'

feature 'Publishing Related Questions Card', js: true do
  include AuthorizationSpecHelper
  include RichTextEditorHelpers

  let(:selector) { 'publishing_related_questions--short_title' }
  let(:title) { 'This is a short title' }

  let(:creator) { create :user, first_name: 'Creator' }
  let!(:paper) { FactoryGirl.create(:paper, :with_integration_journal, creator: creator) }
  let!(:task) { FactoryGirl.create(:publishing_related_questions_task, :with_loaded_card, paper: paper) }

  context 'As creator' do
    before do
      login_as(creator, scope: :user)
      visit "/papers/#{paper.id}"
    end

    let!(:overlay) { Page.view_task_overlay(paper, task) }

    scenario 'sets the short title properly' do
      wait_for_editors
      set_rich_text(editor: selector, text: title)
      wait_for_ajax
      text = get_rich_text(editor: selector)
      expect(text).to eq("<p>#{title}</p>")
    end

    scenario 'upload attachment' do
      within '#published-elsewhere' do
        choose 'Yes'
        find('.fileinput-button').click
        overlay.upload_file(
          element_id: 'file',
          file_name: 'yeti.jpg',
          sentinel: proc { QuestionAttachment.count }
        )
        within('.attachment-item') do
          expect(page).to have_css('.file-link', text: 'yeti.jpg')
        end

        attachment_caption = find('input[name=\'attachment-caption\']')
        attachment_caption.send_keys('Great caption', :tab)
        wait_for_ajax

        expect(find_field('attachment-caption').value).to eq('Great caption')
      end
    end
  end
end
