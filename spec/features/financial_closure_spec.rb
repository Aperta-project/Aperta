require 'rails_helper'

feature 'Financial Closure', js: true do
  let(:admin) { create :user, :site_admin }
  let(:paper)  { create :paper, :with_tasks, :with_valid_plos_author, submitted: false, creator: admin }
  let(:letter_body)  { "Foo Bar, Hello World" }

  scenario 'adds the financial closure card and view it', selenium: true do
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
    expect(page).to have_content 'Financial Disclosure'
  end
end
