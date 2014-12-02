require 'spec_helper'

feature "Editing paper", js: true do
  let(:user) { FactoryGirl.create :user }
  context "As an author on the paper page" do
    before do
      make_user_paper_admin(user, paper)

      sign_in_page = SignInPage.visit
      sign_in_page.sign_in user
      visit edit_paper_path(paper)
    end

    context "on a journal with a doi prefix set" do
      let(:journal) {
        FactoryGirl.create :journal,
                           doi_publisher_prefix: nil,
                           doi_journal_prefix: nil,
                           last_doi_issued: nil
      }

      let(:paper) {
        FactoryGirl.create :paper,
                           :with_tasks,
                           journal: journal,
                           submitted: false,
                           short_title: 'foo bar',
                           creator: user
      }

      scenario "it adds the DOI to the URL" do
        within ".task-list" do
          expect(page).to_not have_css ".doi"
        end

        expect(page.current_path).to eq "/papers/#{paper.id}/edit"
      end
    end

    context "on a journal without a doi prefix set", js: true do
      let(:journal) {
        FactoryGirl.create :journal,
        doi_publisher_prefix: 'vicious',
        doi_journal_prefix: 'robots',
        last_doi_issued: '8887'
      }

      let(:paper) {
        FactoryGirl.create :paper,
        :with_tasks,
        journal: journal,
        submitted: false,
        short_title: 'foo bar',
        creator: user,
        doi: "vicious/robots.8888"
      }

      scenario "it retains the paper's internal id in the URL", selenium: true do
        within ".task-list .doi" do
          expect(page).to have_content "DOI: vicious/robots.8888"
        end
        expect(page.current_path).to eq "/papers/vicious/robots.8888/edit"
      end
    end

  end
end
