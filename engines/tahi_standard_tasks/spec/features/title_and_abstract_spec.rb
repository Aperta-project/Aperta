require 'rails_helper'
include RichTextEditorHelpers

feature 'Title And Abstract Task', js: true do
  let(:creator) { FactoryGirl.create :user }
  let!(:paper) { FactoryGirl.create(:paper, :with_integration_journal, creator: creator) }
  let!(:task) { FactoryGirl.create(:title_and_abstract_task, :with_loaded_card, paper: paper) }

  context 'As creator' do
    before do
      login_as(creator, scope: :user)
      visit "/papers/#{paper.id}"
      Page.view_task_overlay(paper, task)
      wait_for_ajax
    end

    scenario 'title prevents entering line breaks' do
      editor_name = 'article-title-input'
      set_rich_text(editor: editor_name, text: "ab")

      within_editor_iframe(editor_name) do
        el = page.find('body')
        el.send_keys("\nc")
        expect(el).to have_content('abc')
      end
    end

    scenario 'abstract allows entering line breaks' do
      editor_name = 'article-abstract-input'
      set_rich_text(editor: editor_name, text: "ab")

      within_editor_iframe(editor_name) do
        el = page.find('body')
        el.send_keys("\nc")
        expect(el).to have_content("ab\nc")
      end
    end
  end
end
