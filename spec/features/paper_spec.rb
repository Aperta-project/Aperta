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

    scenario "Author edits paper", selenium: true do
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

    it "shows validations", selenium: true do
      click_link(@paper.title)
      find('.workflow-link').click
      click_link('Billing')


      find(".affiliation-field b[role='presentation']").click #slect PFA from dropdown
      find("li.select2-result div", :text => /PLOS Publication Fee Assistance Program \(PFA\)/).click #slect PFA from dropdown

      within(".question-dataset") do 
        find("input[id='plos_billing.pfa_question_1-yes']").click  #doens't work: find("#plos_billing.pfa_question_1-yes").click
        find("input[name='plos_billing.pfa_question_1b']").set "foo"

        binding.pry

      end

      #fill in crap
      #
      #check for errors
      #check for disabled
    end
  end
end
