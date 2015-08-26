require 'rails_helper'

feature "Editing paper", selenium: true, js: true do
  let(:user) { FactoryGirl.create :user }
  let(:journal) {
    FactoryGirl.create :journal,
    doi_publisher_prefix: nil,
    doi_journal_prefix: nil,
    last_doi_issued: nil
  }
  let(:paper_type) {
    journal.manuscript_manager_templates.pluck(:paper_type).first
  }

  context "As an author on the paper page" do

    before do
      assign_journal_role(journal, user, :admin)
      login_as user
      visit "/"
    end

    context "on a journal without a doi prefix set" do

      scenario "it doesn't contain any doi artifacts" do
        visit '/'
        click_button 'Create New Submission'
        fill_in 'paper-short-title', with: "A paper with no doi"
        p = PageFragment.new(find('#overlay'))
        p.select2(journal.name, css: '.paper-new-journal-select')
        p.select2(paper_type,  css: '.paper-new-paper-type-select')
        click_button 'Create Document'
        wait_for_ajax
        expect(page.current_path).to match %r{/papers/\d+/edit}
        within "#paper-container" do
          expect(page).to_not have_text("DOI:")
        end
      end
    end

    context "on a journal with a doi prefix set" do
      before do
        journal.update_attributes(doi_publisher_prefix: 'vicious',
                                  doi_journal_prefix: 'robots',
                                  last_doi_issued: '8887')
      end

      scenario "shows the doi on the page" do
        visit '/'
        click_button 'Create New Submission'
        fill_in 'paper-short-title', with: "A paper with doi"
        p = PageFragment.new(find('#overlay'))
        p.select2(journal.name, css: '.paper-new-journal-select')
        p.select2(paper_type,  css: '.paper-new-paper-type-select')
        click_button 'Create Document'
        wait_for_ajax

        within ".task-list-doi" do
          expect(page).to have_content "DOI: vicious/robots.8888"
        end
        expect(page.current_path).to eq("/papers/#{Paper.last.id}/edit")
      end
    end

  end
end
