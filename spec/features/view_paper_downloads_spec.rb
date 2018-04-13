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
require 'support/pages/paper_page'

# rubocop:disable Metrics/BlockLength
feature 'Viewing Versions:', js: true do
  let(:creator) { FactoryGirl.create :user }

  context 'When viewing a paper with more than one version,' do
    let(:paper) do
      FactoryGirl.create :paper_with_phases,
        :with_integration_journal,
        :version_with_file_type,
        :with_versions_across_file_types,
        creator: creator
    end
    let!(:task) do
      FactoryGirl.create :custom_card_task,
        paper: paper,
        phase: paper.phases.first
    end

    let(:user) { creator }

    before do
      login_as(user, scope: :user)
      visit '/'
      click_link(paper.title)
    end

    scenario 'the user views multiple versions of a paper', selenium: true do
      page = PaperPage.new
      page.downloads_link.click
      wait_for_ajax

      expect(page.find('tbody .paper-downloads-row:nth-child(1) .paper-downloads-version')).to have_content 'Draft'
      expect(page.find('tbody .paper-downloads-row:nth-child(2) .paper-downloads-version')).to have_content 'v1.0'
      expect(page.find('tbody .paper-downloads-row:nth-child(3) .paper-downloads-version')).to have_content 'v0.2'
      expect(page.find('tbody .paper-downloads-row:nth-child(4) .paper-downloads-version')).to have_content 'v0.1'
      expect(page.find('tbody .paper-downloads-row:nth-child(5) .paper-downloads-version')).to have_content 'v0.0'

      expect(page.find('tbody .paper-downloads-row:nth-child(1)')).to have_css '.paper-downloads-link--pdf'
      expect(page).not_to have_selector('tbody .paper-downloads-row:nth-child(1) .paper-downloads-link--docx')

      expect(page.find('tbody .paper-downloads-row:nth-child(2)')).to have_css '.paper-downloads-link--pdf'
      expect(page).not_to have_selector('tbody .paper-downloads-row:nth-child(2) .paper-downloads-link--docx')

      expect(page.find('tbody .paper-downloads-row:nth-child(3)')).to have_css '.paper-downloads-link--pdf'
      expect(page).not_to have_selector('tbody .paper-downloads-row:nth-child(3) .paper-downloads-link--docx')

      expect(page.find('tbody .paper-downloads-row:nth-child(4)')).to have_css '.paper-downloads-link--pdf'
      expect(page.find('tbody .paper-downloads-row:nth-child(4)')).to have_css '.paper-downloads-link--docx'

      expect(page.find('tbody .paper-downloads-row:nth-child(5)')).to have_css '.paper-downloads-link--pdf'
      expect(page.find('tbody .paper-downloads-row:nth-child(5)')).to have_css '.paper-downloads-link--docx'
    end
  end
end
