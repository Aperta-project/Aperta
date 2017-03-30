require 'rails_helper'

feature 'Viewing Versions:', js: true, flaky: true do
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
      FactoryGirl.create :ethics_task,
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

      expect(page.find('tbody .paper-downloads-row:nth-child(3)')).to have_css '.paper-downloads-link--docx'
      expect(page.find('tbody .paper-downloads-row:nth-child(3)')).to have_css '.paper-downloads-link--pdf'

      expect(page.find('tbody .paper-downloads-row:nth-child(4)')).to have_css '.paper-downloads-link--pdf'
      expect(page).not_to have_selector('tbody .paper-downloads-row:nth-child(4) .paper-downloads-link--docx')

      expect(page.find('tbody .paper-downloads-row:nth-child(5)')).to have_css '.paper-downloads-link--docx'
      expect(page.find('tbody .paper-downloads-row:nth-child(5)')).to have_css '.paper-downloads-link--pdf'
    end
  end
end
