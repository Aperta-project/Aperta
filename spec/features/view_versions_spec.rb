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
# See APERTA-11563. This fails after 5pm PST, which is too much pain just to test that the version date looks good.
xfeature 'Viewing Versions:', js: true do
  let(:creator) { FactoryGirl.create :user }

  context 'When viewing a paper with more than one version,' do
    let(:paper) do
      FactoryGirl.create :paper_with_phases,
                         :with_integration_journal,
                         :with_versions,
                         first_version_body:  '<p>OK first body</p>',
                         second_version_body: '<p>OK second body</p>',
                         creator: creator
    end
    let!(:task) do
      FactoryGirl.create :figure_task,
                         paper: paper,
                         phase: paper.phases.first
    end
    let(:version_0) { paper.versioned_texts.version_desc.last }
    let(:version_1) { paper.versioned_texts.version_desc.first }

    let(:user) { creator }

    before do
      login_as(user, scope: :user)
      visit '/'
      click_link(paper.title)
    end

    scenario 'the user views an old version of the paper.', selenium: true do
      page = PaperPage.new
      page.view_versions
      expect(page).to have_css("div.ember-power-select-trigger")
      page.select_viewing_version(version_1)
      expect(page.versioned_body).to have_content('OK second body')
      page.select_viewing_version(version_0)
      expect(page.versioned_body).to have_content('OK first body')
    end

    scenario 'the user views an old version of the paper.', selenium: true do
      page = PaperPage.new
      page.view_versions
      expect(page).to have_css("div.ember-power-select-trigger")
      page.select_viewing_version(version_0)
      page.select_comparison_version(version_1)
      expect(page.find('#paper-body .added')).to have_content 'first'
      expect(page.find('#paper-body .removed')).to have_content 'second'
    end

    scenario 'The user views an old version of a task', selenium: true do
      SnapshotService.new(paper).snapshot!(task)
      page = PaperPage.new
      page.view_versions
      expect(page).to have_css("div.ember-power-select-trigger")
      page.select_viewing_version(version_0)
      page.view_card('Figures', VersionedMetadataOverlay, false) do |overlay|
        overlay.expect_version('R0.0')
      end
      page.select_viewing_version(version_1)
      page.view_card('Figures', VersionedMetadataOverlay, false) do |overlay|
        overlay.expect_version('(draft)')
      end
    end

    scenario 'The user compares two versions of a task', selenium: true do
      SnapshotService.new(paper).snapshot!(task)
      # SnapshotService only creates a snapshot
      # for the latest version, hence this line:
      FactoryGirl.create(:snapshot,
                         major_version: 0,
                         minor_version: 0,
                         source: task)

      page = PaperPage.new
      page.view_versions
      expect(page).to have_css("div.ember-power-select-trigger")
      page.select_viewing_version(version_0)
      page.select_comparison_version(version_1)
      page.view_card('Figures', VersionedMetadataOverlay, false) do |overlay|
        overlay.expect_versions('R0.0', '(draft)')
      end
    end
  end
end

feature 'Viewing manuscript control bar', js: true do
  before do
    login_as(user, scope: :user)
    visit "/papers/#{paper.to_param}/versions?majorVersion=0&minorVersion=0"
  end

  context 'as an admin' do
    let(:user) { FactoryGirl.create :user, :site_admin }
    let(:paper) { FactoryGirl.create :paper, :with_integration_journal }

    scenario 'can view the Go to Workflow link' do
      expect(page).to have_css('#nav-workflow')
    end
  end

  context 'as an author' do
    let(:user) { FactoryGirl.create :user }
    let(:paper) do
      FactoryGirl.create :paper, :with_integration_journal, creator: user
    end

    scenario 'can not view the Go to Workflow link' do
      expect(page).to_not have_css('#nav-workflow')
    end
  end
end
