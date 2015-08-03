require 'rails_helper'

feature "Viewing Versions:", js: true do
  let(:user) { FactoryGirl.create :user }

  context "When viewing a paper with more than one version," do
    let(:paper) do
      FactoryGirl.create :paper,
                         :with_versions,
                         :with_tasks,
                         :with_valid_plos_author,
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
      page = EditPaperPage.new
      page.version_button.click
      wait_for_ajax
      expect(page.versioned_body).to include "OK second body"

      select paper.versioned_texts.first.version_string, from: "view_version"
      wait_for_ajax
      expect(page.versioned_body).to include "I am the very model"
    end
  end
end
