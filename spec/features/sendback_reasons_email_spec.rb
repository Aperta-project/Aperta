require 'rails_helper'

feature 'Publishing Related Questions Card', js: true do
  include AuthorizationSpecHelper
  include RichTextEditorHelpers

  let(:title) { 'This is a short title' }

  let(:creator) { create :user, first_name: 'Creator' }
  let!(:paper) { FactoryGirl.create(:paper, :with_integration_journal, creator: creator) }

  let!(:task) {
    AnswerableFactory.create(
      FactoryGirl.create(:custom_card_task, paper: paper),
      questions: [
        {
          content_type: 'tech-check',
          value_type: 'boolean',
          answer: 'false',
          questions: [
            {
              content_type: 'sendback-reasons',
              value_type: 'boolean',
              answer: 'true',
              questions: [
                {
                  content_type: 'checkbox',
                  value_type: 'boolean',
                  answer: 'true'
                },
                {
                  content_type: 'checkbox',
                  value_type: 'boolean',
                  answer: 'true'
                },
                {
                  content_type: 'paragraph-input',
                  ident: 'sendback-answers',
                  value_type: 'html',
                  answer: 'This is being sent back becuase it is bad'
                }
              ]
            }
          ]
        },

        {
          content_type: 'tech-check-email',
          questions: [
            {
              content_type: 'paragraph-input',
              value_type: 'html',
              ident: 'tech-check-email--email-intro',
              answer: 'this is the intro'
            },
            {
              content_type: 'paragraph-input',
              value_type: 'html',
              ident: 'tech-check-email--email-footer',
              answer: 'this is the footer'
            }
          ]
        }
      ]
    )
  }

  # let(:selector) { 'publishing_related_questions--short_title' }
  # let!(:task) { FactoryGirl.create(:tech_check_task, :with_loaded_card, paper: paper) }

  context 'As creator' do
    before do
      login_as(creator, scope: :user)
      visit "/papers/#{paper.id}"
    end

    let!(:overlay) { Page.view_task_overlay(paper, task) }

    scenario 'sets the short title properly' do
      wait_for_editors
      set_rich_text(editor: 'sendback-answer', text: 'This is being sent back becuase it is bad')
      set_rich_text(editor: 'tech-check-email--email-intro', text: 'this is the intro')
      set_rich_text(editor: 'tech-check-email--email-footer', text: 'this is the footer')

      wait_for_ajax
      # text = get_rich_text(editor: selector)
      # expect(text).to eq(title)
    end

    # scenario 'upload attachment' do
    #   within '#published-elsewhere' do
    #     choose 'Yes'
    #     find('.fileinput-button').click
    #     overlay.upload_file(
    #       element_id: 'file',
    #       file_name: 'yeti.jpg',
    #       sentinel: proc { QuestionAttachment.count }
    #     )
    #     within('.attachment-item') do
    #       expect(page).to have_css('.file-link', text: 'yeti.jpg')
    #     end

    #     attachment_caption = find('input[name=\'attachment-caption\']')
    #     attachment_caption.send_keys('Great caption', :tab)
    #     wait_for_ajax

    #     expect(find_field('attachment-caption').value).to eq('Great caption')
    #   end
    # end
  end
end
