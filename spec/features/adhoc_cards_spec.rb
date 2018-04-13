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
require 'support/pages/overlays/adhoc_overlay'

feature 'Adhoc cards', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let(:admin) { FactoryGirl.create :user, :site_admin }
  let(:paper) do
    FactoryGirl.create :paper_with_task,
                       :with_integration_journal,
                       task_params: { type: 'AdHocTask' },
                       creator: author
  end
  let(:overlay) { AdhocOverlay.new }
  let(:ad_hoc_task) { AdHocTask.find_by(paper: paper) }

  context 'As a participant' do
    before do
      ad_hoc_task.add_participant(author)
      ad_hoc_task.update!(body: [[{ type: "attachments", value: "Please select a file." }]])
      paper.tasks.each { |t| t.add_participant(author) }
      login_as(author, scope: :user)
      Page.view_task paper.tasks.first
    end

    scenario 'uploads an image to ad-hoc card' do
      overlay.upload_attachment('yeti.jpg')
      within('.attachment-item') do
        expect(page).to have_css('.file-link', text: 'yeti.jpg')
      end
    end

    scenario 'replaces an attachment on ad-hoc card' do
      overlay.upload_attachment('yeti.jpg')
      find('.file-link', text: 'yeti.jpg')
      overlay.replace_attachment('yeti2.jpg')
      expect(page).to have_css('.file-link', text: 'yeti2.jpg')
    end

    scenario 'edits attachment caption on ad-hoc card' do
      overlay.upload_attachment('yeti.jpg')
      find('.file-link', text: 'yeti.jpg')

      fill_in('attachment-caption', with: 'Great caption')
      expect(find_field('attachment-caption').value).to eq('Great caption')
    end

    scenario 'deletes attachment from an ad-hoc card' do
      overlay.upload_attachment('yeti.jpg')
      find('.file-link', text: 'yeti.jpg')
      find('.delete-attachment').click
      expect(page).not_to have_css('.attachment-item')
    end
  end

  context 'As someone who can manage email participants' do
    before do
      login_as(admin, scope: :user)
      Page.view_task paper.tasks.first
    end

    scenario 'allows sending email from ad-hoc card' do
      overlay.find('.fa-plus').click
      overlay.find('.adhoc-toolbar-item--email').click
      overlay.fill_in('Enter a subject', with: 'subject')
      overlay.find('.email-body').click
      overlay.find('.email-body').send_keys('body')
      overlay.find_all('.button-secondary', text: 'SAVE').first.click
      overlay.find('.email-send-participants').click
      overlay.find_all('.add-participant-button', text: '+').first.click

      find(".ember-power-select-search-input").set('author')
      wait_for_ajax
      find(".ember-power-select-option").click
      overlay.find('.send-email-action').click

      expect(overlay).to have_text('Your email has been sent.')
    end
  end
end
