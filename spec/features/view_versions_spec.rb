require 'rails_helper'

feature "Viewing Versions:", js: true do
  let(:user) { FactoryGirl.create :user }

  context "When viewing a paper with more than one version," do
    let(:paper) do
      FactoryGirl.create :paper,
                         :with_versions,
                         first_version_body:  '<p>OK first body</p>',
                         second_version_body: '<p>OK second body</p>',
                         creator: user
    end

    before do
      paper.reload
      paper.allow_edits!
      login_as user
      visit "/"

      click_link(paper.title)
    end

    scenario "the user views an old version of the paper.", selenium: true do
      page = PaperPage.new
      page.version_button.click
      wait_for_ajax
      select paper.versioned_texts.version_desc.first.version_string, from: "view_version"

      expect(page.versioned_body).to have_content("OK second body")

      select paper.versioned_texts.version_desc.last.version_string, from: "view_version"
      wait_for_ajax

      expect(page.versioned_body).to have_content("OK first body")
    end

    scenario "the user views an old version of the paper.", selenium: true do
      page = PaperPage.new
      page.version_button.click
      wait_for_ajax
      select paper.versioned_texts.version_desc.last.version_string, from: "view_version"


      select paper.versioned_texts.version_desc.first.version_string, from: "compare_version"
      wait_for_ajax

      expect(page.find("#paper-body .added")).to have_content "OK first body"
      expect(page.find("#paper-body .removed")).to have_content "OK second body"
    end
  end
end
