# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'support/rich_text_editor_helpers'

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
    end

    scenario 'title prevents entering line breaks' do
      editor_name = 'article-title-input'
      set_rich_text(editor: editor_name, text: "ab")

      within_editor_iframe(editor_name) do
        el = page.find('body')
        el.click
        el.send_keys("\nc")
        expect(el).to have_content('abc')
      end
    end

    scenario 'abstract allows entering line breaks' do
      editor_name = 'article-abstract-input'
      set_rich_text(editor: editor_name, text: "ab")

      within_editor_iframe(editor_name) do
        el = page.find('body')
        el.click
        el.send_keys("\nc")
        expect(el).to have_content("ab\nc")
      end
    end
  end
end
