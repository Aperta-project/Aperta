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

feature 'Production Metadata Card', js: true do
  let(:admin) { create :user, :site_admin, first_name: 'Admin' }
  let(:author) { create :user, first_name: 'Author' }
  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let!(:paper) do
    create :paper, journal: journal, creator: author
  end
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let!(:production_metadata_task) do
    create :production_metadata_task, :with_loaded_card, paper: paper, phase: phase
  end

  before do
    login_as admin
    visit "/papers/#{paper.id}/tasks/#{production_metadata_task.id}"
    wait_for_editors
  end

  describe 'completing a Production Metadata card' do
    describe 'adding a volume number' do
      it 'does not allows alphas to be entered' do
        fill_in('production_metadata--volume_number', with: 'alpha characters')
        volume_number_input = page.first("input[name='production_metadata--volume_number']")
        expect(volume_number_input.value).not_to eq 'alpha characters'
      end

      it 'allows numbers to be entered' do
        fill_in('production_metadata--volume_number', with: 1234)
        volume_number_input = page.first("input[name='production_metadata--volume_number']")
        expect(volume_number_input.value).to eq '1234'
      end
    end

    describe 'adding an issue number' do
      it 'does not allows alphas to be entered' do
        fill_in('production_metadata--issue_number', with: 'alpha characters')
        issue_number_input = page.first("input[name='production_metadata--issue_number']")
        expect(issue_number_input.value).not_to eq 'alpha characters'
      end

      it 'allows numbers to be entered' do
        fill_in('production_metadata--issue_number', with: 1234)
        issue_number_input = page.first("input[name='production_metadata--issue_number']")
        expect(issue_number_input.value).to eq '1234'
      end
    end

    describe 'filling in the entire card' do
      provenance = 'It came from outer space.'
      comments = {
        production_notes: 'Cheap cardboard sets.',
        special_handling_instructions: 'Wear radiation suit.'
      }

      it 'persists information' do
        page.fill_in 'production_metadata--publication_date', with: '08/31/2015'
        page.execute_script "$(\"input[name='production_metadata--publication_date']\").trigger('change')"
        page.fill_in 'production_metadata--volume_number', with: '1234'
        page.execute_script "$(\"input[name='production_metadata--volume_number']\").trigger('change')"
        page.fill_in 'production_metadata--issue_number', with: '5678'
        page.execute_script "$(\"input[name='production_metadata--issue_number']\").trigger('change')"
        page.fill_in 'production_metadata--provenance', with: provenance
        page.execute_script "$(\"input[name='production_metadata--provenance']\").trigger('change')"

        comments.each do |key, value|
          set_rich_text editor: "production_metadata--#{key}", text: value
        end

        wait_for_ajax

        visit "/papers/#{paper.id}/tasks/#{production_metadata_task.id}"
        wait_for_editors

        find('h1', text: 'Production Metadata')
        within '.task-main-content' do
          expect(page).to have_field('production_metadata--volume_number', with: "1234")
          expect(page).to have_field('production_metadata--issue_number', with: "5678")
          expect(page).to have_field('production_metadata--publication_date', with: "08/31/2015")
          expect(page).to have_field('production_metadata--provenance', with: provenance)

          comments.each do |key, value|
            text = get_rich_text(editor: "production_metadata--#{key}")
            expect(text).to eq "<p>#{value}</p>"
          end
        end
      end
    end

    context 'clicking complete' do
      describe 'with invalid input in required fields' do
        it 'shows an error' do
          find('.task-completed').click
          expect(find(".volume-number")).to have_text("Must be a whole number")
          expect(find(".issue-number")).to have_text("Must be a whole number")
        end
      end
    end
  end
end
