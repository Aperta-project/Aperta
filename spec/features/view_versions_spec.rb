require 'rails_helper'

feature 'Viewing Versions:', js: true do
  let(:user) { FactoryGirl.create :user }

  context 'When viewing a paper with more than one version,' do
    let(:paper) do
      FactoryGirl.create :paper_with_phases,
                         :with_versions,
                         first_version_body:  '<p>OK first body</p>',
                         second_version_body: '<p>OK second body</p>',
                         creator: user
    end
    let(:task) do
      FactoryGirl.create :ethics_task,
                         paper: paper,
                         phase: paper.phases.first
    end
    let(:version_0) { paper.versioned_texts.version_desc.last }
    let(:version_1) { paper.versioned_texts.version_desc.first }

    before do
      paper.reload
      login_as(user, scope: :user)
      visit '/'

      click_link(paper.title)
    end

    scenario 'the user views an old version of the paper.', selenium: true do
      page = PaperPage.new
      page.version_button.click
      wait_for_ajax

      page.select_viewing_version(version_1)

      expect(page.versioned_body).to have_content('OK second body')

      page.select_viewing_version(version_0)

      expect(page.versioned_body).to have_content('OK first body')
    end

    scenario 'the user views an old version of the paper.', selenium: true do
      page = PaperPage.new
      page.version_button.click
      wait_for_ajax
      page.select_viewing_version(version_0)

      page.select_comparison_version(version_1)

      expect(page.find('#paper-body .added')).to have_content 'OK first body'
      expect(page.find('#paper-body .removed')).to have_content 'OK second body'
    end

    scenario 'The user views an old version of a task', selenium: true do
      SnapshotService.new(paper).snapshot!(task)
      page = PaperPage.new
      page.version_button.click
      wait_for_ajax
      page.select_viewing_version(version_0)

      page.view_card('Ethics', VersionedMetadataOverlay) do |overlay|
        overlay.expect_version('R0.0')
      end

      page.select_viewing_version(version_1)

      page.view_card('Ethics', VersionedMetadataOverlay) do |overlay|
        overlay.expect_version('R1.0')
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
      page.version_button.click
      wait_for_ajax
      page.select_viewing_version(version_0)
      page.select_comparison_version(version_1)

      page.view_card('Ethics', VersionedMetadataOverlay) do |overlay|
        overlay.expect_versions('R0.0', 'R1.0')
      end
    end
  end
end

feature 'Viewing manuscript control bar', js: true do
  before do
    login_as(user, scope: :user)
    visit "/papers/#{paper.id}/versions?majorVersion=0&minorVersion=0"
  end

  context 'as an admin' do
    let(:user) { FactoryGirl.create :user, :site_admin }
    let(:paper) { FactoryGirl.create :paper }

    scenario 'can view the Go to Workflow link' do
      expect(page).to have_css('#go-to-workflow')
    end
  end

  context 'as an author' do
    let(:user) { FactoryGirl.create :user }
    let(:paper) { FactoryGirl.create :paper, creator: user }

    scenario 'can not view the Go to Workflow link' do
      expect(page).to_not have_css('#go-to-workflow')
    end
  end
end
