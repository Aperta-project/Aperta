require 'rails_helper'

feature 'Financial Closure', js: true do
  let(:admin) { create :user, :site_admin }
  let(:paper)  { create :paper, :with_tasks, :with_valid_plos_author, submitted: false, creator: admin }
  let(:letter_body)  { "Foo Bar, Hello World" }

  scenario 'finishes the cover letter and save it', selenium: true do
    sign_in_page = SignInPage.visit
    edit_page = sign_in_page.sign_in admin

    click_link(paper.title)
    click_link "Workflow"
    first('a', text: 'ADD NEW CARD').click
    select2_container = find(".select2-container")
    select2_container.find(".select2-choice").click
    find(:xpath, "//body").find(".select2-with-searchbox input.select2-input").set("Financial Disclosure")
    within(".overlay-action-buttons") do
      find("button", text: "ADD").click
    end
    find("div.card-content", text: 'Financial Disclosure').click

    # first("div", text: "Financial Disclosure").click
    # save_and_open_page
    find('input', text: 'Yes').click
    expect(page).to have_contentb 'Funder'
    # expect(page).to have_content 'Cover Letter'
    # find('.card-content', text: 'Cover Letter').click
    # expect(page).to have_css('.edit-cover-letter')
    #
    # within '.edit-cover-letter' do
    #   find('.taller-textarea').set(letter_body)
    #   click_button 'Save'
    # end
    #
    # expect(page).to_not have_css('.edit-cover-letter')
    # expect(page).to have_css('.preview-cover-letter')
    # within '.preview-cover-letter' do
    #   expect(page).to have_content letter_body
    #   click_button 'Make Changes'
    # end
    #
    # expect(page).to have_css('.edit-cover-letter')
  end
end
