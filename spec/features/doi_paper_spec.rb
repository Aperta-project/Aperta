require 'rails_helper'

feature "Paper DOI Generation", selenium: true, js: true do
  let(:user) { FactoryGirl.create :user }

  context "As an author on the paper page" do
    before do
      assign_journal_role(journal, user, :admin)
      login_as(user, scope: :user)
      visit "/"
    end

    context "on a journal without a doi prefix set" do
      let(:journal) do
        FactoryGirl.create(
          :journal,
          :with_roles_and_permissions,
          doi_publisher_prefix: nil,
          doi_journal_prefix: nil,
          last_doi_issued: nil
        )
      end

      let(:paper_type) {
        journal.manuscript_manager_templates.pluck(:paper_type).first
      }

      let(:paper) {
        FactoryGirl.create(:paper, journal: journal, paper_type: paper_type)
      }

      scenario "it doesn't contain any doi artifacts" do
        visit "/papers/#{paper.id}"
        within "#paper-container" do
          expect(page).to_not have_text("Manuscript ID")
        end
      end
    end

    context "on a journal with a doi prefix set" do
      let(:journal) {
        FactoryGirl.create :journal, :with_roles_and_permissions,
        doi_publisher_prefix: 'vicious',
        doi_journal_prefix: 'robots',
        last_doi_issued: '8887'
      }

      let(:paper_type) {
        journal.manuscript_manager_templates.pluck(:paper_type).first
      }

      let(:paper) {
        FactoryGirl.create(:paper, journal: journal, paper_type: paper_type)
      }

      scenario "shows the manuscript id (derived from doi) on the page" do
        visit "/papers/#{paper.id}"

        within ".task-list-doi" do
          expect(page).to have_content "Manuscript ID: robots.8888"
        end
      end
    end

  end
end
