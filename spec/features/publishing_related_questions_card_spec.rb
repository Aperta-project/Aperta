require 'rails_helper'

feature 'Publishing Related Questions Card', js: true do
  include AuthorizationSpecHelper

  let(:creator) { create :user, first_name: 'Creator' }
  let!(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: creator)
  end
  let!(:task) do
    FactoryGirl.create(:publishing_related_questions_task, paper: paper)
  end

  def short_title_selector
    '.publishing-related-questions-short-title .format-input-field'
  end

  context 'As creator' do
    before do
      login_as(creator, scope: :user)
      visit "/papers/#{paper.id}"
    end

    let!(:overlay) { Page.view_task_overlay(paper, task) }

    scenario 'sets the short title properly' do
      content_editable = find(short_title_selector)

      # <br> tags are only added when the space key is hit. So we clear the
      content_editable.set('T')
      content_editable.send_keys('his is a short title', :tab)
      # we need to have the field save after pressing the tab key
      # but there is no DOM change in the browser that we can use to determine
      # that, so we resort to wait_for_ajax.  it's a more stable option than
      # checking on the database end
      # Hack to wait for change in db
      10.times do
        sleep 1
        next unless paper.reload.short_title.match(/short title/)
        expect(paper.short_title).not_to include('<br')
        expect(paper.short_title).to eq('This is a short title')
      end
    end

    scenario 'upload attachent' do
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
