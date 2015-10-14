require 'rails_helper'

feature "Editing paper", js: true do
  let(:user) { FactoryGirl.create :user }

  context "As an author" do
    let(:paper) { FactoryGirl.create :paper, :with_tasks, :with_valid_author, creator: user }

    before do
      make_user_paper_admin(user, paper)

      login_as(user, scope: :user)
      visit "/"

      click_link(paper.title)
    end

    scenario "Author edits paper" do
      # editing the paper
      edit_paper = PaperPage.new
      edit_paper.start_editing
      edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
      edit_paper.body = "Contrary to popular belief"
      # check if changes are applied
      expect(edit_paper).to have_paper_title("Lorem Ipsum Dolor Sit Amet")
      expect(edit_paper.has_body_text?("Contrary to popular belief")).to be(true)
      edit_paper.save
      edit_paper.reload
      # check if changes are persisted
      expect(edit_paper).to have_paper_title("Lorem Ipsum Dolor Sit Amet")
      expect(edit_paper.has_body_text?("Contrary to popular belief")).to be(true)
    end
  end

  context "with a billing task" do

    before do
      @user  = FactoryGirl.create :user, :site_admin
      @paper = FactoryGirl.create :paper_with_task, creator: @user, task_params: { title: "Billing", type: "PlosBilling::BillingTask", role: "author" }
      login_as @user
      visit "/"
    end

    it "shows validations" do
      click_link(@paper.title)
      find('.workflow-link').click
      click_link('Billing')

      expect(find("input#task_completed")[:disabled]).to be(nil) # not disabled at start

      find(".affiliation-field b[role='presentation']").click # open payment types dropdown
      find("div.select2-result-label", :text => /PLOS Publication Fee Assistance Program \(PFA\)/).click #select PFA from dropdown

      expect(find("input#task_completed")[:disabled]).to be(nil)
      expect(page).not_to have_selector(".overlay-completed-checkbox .error-message") # make sure no error msg

      within(".question-dataset") do
        find("input[id='plos_billing.pfa_question_1-yes']").click  # doesn't work: find("#plos_billing.pfa_question_1-yes").click
        find("input[id='plos_billing.pfa_question_2-yes']").click
        find("input[id='plos_billing.pfa_question_3-yes']").click
        find("input[id='plos_billing.pfa_question_4-yes']").click

        # numeric fields
        ['pfa_question_1b', 'pfa_question_2b', 'pfa_question_3a', 'pfa_question_4a', 'pfa_amount_to_pay'].each do |ident|
          find("input[name='plos_billing.#{ident}']").set "foo"
          expect(find("#error-for-#{ident}")).to have_content("Must be a number and contain no symbols, or letters")
        end
      end

      expect(find("input#task_completed")[:disabled]).to be_truthy # complete is disabled
      expect(find(".overlay-completed-checkbox .error-message").text).to eq("Errors in form") # shows error

      # change to a different payment system
      find(".affiliation-field b[role='presentation']").click # open payment types dropdown
      find("div.select2-result-label", :text => /I will pay the full fee/).click # change back to non-pfa
      expect(find("input#task_completed")[:disabled]).to be(nil) # not disabled after change
      expect(page).not_to have_selector(".overlay-completed-checkbox .error-message") # make sure no error msg
    end
  end
end
