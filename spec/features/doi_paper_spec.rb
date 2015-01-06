require 'spec_helper'

feature "Editing paper", selenium: true, js: true do
  let(:user) { FactoryGirl.create :user }
  let(:journal) {
    FactoryGirl.create :journal,
    doi_publisher_prefix: nil,
    doi_journal_prefix: nil,
    last_doi_issued: nil
  }

  context "As an author on the paper page" do
    before do
      assign_journal_role(journal, user, :admin)
      sign_in_page = SignInPage.visit
      sign_in_page.sign_in user
    end

    context "on a journal without a doi prefix set" do

      scenario "it doesn't contain any doi artifacts" do
        visit '/'
        click_button 'Create New Submission'
        within('.overlay-container') do |page|
          fill_in 'paper-short-title', with: "A paper with no doi"
          click_button 'Create'
        end
        wait_for_ajax
        expect(page.current_path).to match %r{/papers/\d+/edit}
        within ".task-list" do
          expect(page).to_not have_css ".doi"
        end
      end
    end

    context "on a journal with a doi prefix set" do
      before do
        journal.update_attributes(doi_publisher_prefix: 'vicious',
                                  doi_journal_prefix: 'robots',
                                  last_doi_issued: '8887')
      end

      scenario "shows the doi on the page and in the URL" do
        visit '/'
        click_button 'Create New Submission'
        within('.overlay-container') do |page|
          fill_in 'paper-short-title', with: "A paper with doi"
          click_button 'Create'
        end
        wait_for_ajax

        within ".task-list-doi" do
          expect(page).to have_content "DOI: vicious/robots.8888"
        end
        expect(page.current_path).to eq "/papers/vicious/robots.8888/edit"
      end

      scenario "shows the doi on the page when paper is submitted or uneditable" do
        visit '/'
        click_button 'Create New Submission'
        within('.overlay-container') do |page|
          fill_in 'paper-short-title', with: "A paper with doi"
          click_button 'Create'
        end
        wait_for_ajax

        click_link 'Workflow'
        uncheck 'paper-editable'
        click_link 'Manuscript'

        within ".task-list-doi" do
          expect(page).to have_content "DOI: vicious/robots.8888"
        end
        expect(page.current_path).to eq "/papers/vicious/robots.8888"
      end
    end

  end
end
