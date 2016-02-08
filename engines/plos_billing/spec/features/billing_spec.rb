require 'rails_helper'

feature "Billing feature", js: true do
  let(:user) { FactoryGirl.create :user }

  context "with a billing task" do

    before do
      @user  = FactoryGirl.create :user, :site_admin
      @paper = FactoryGirl.create :paper_with_task, creator: @user, task_params: { title: "Billing", type: "PlosBilling::BillingTask", old_role: "author" }
      login_as @user
      visit "/papers/#{@paper.id}/tasks/#{@paper.tasks.first.id}"
    end

    it "shows validations", vcr: { cassette_name: "ned_countries" } do
      expect(find(".task-completed")[:disabled]).to be(nil) # not disabled at start

      p = PageFragment.new(find('.overlay'))
      p.select2("PLOS Publication Fee Assistance Program (PFA)", css: '.payment-method')

      expect(find(".task-completed")[:disabled]).to be(nil)
      expect(page).not_to have_selector(".task-completed-section .error-message") # make sure no error msg

      within(".question-dataset") do
        find("input[id*='plos_billing--pfa_question_1-yes']").click
        find("input[id*='plos_billing--pfa_question_2-yes']").click
        find("input[id*='plos_billing--pfa_question_3-yes']").click
        find("input[id*='plos_billing--pfa_question_4-yes']").click

        # numeric fields
        ['plos_billing--pfa_question_1b', 'plos_billing--pfa_question_2b', 'plos_billing--pfa_question_3a', 'plos_billing--pfa_question_4a', 'plos_billing--pfa_amount_to_pay'].each do |ident|
          find("input[name*='#{ident}']").set "foo"
          expect(find("#error-for-#{ident}")).to have_content("Must be a number and contain no symbols, or letters")
        end
      end

      expect(find(".task-completed")[:disabled]).to be_truthy # complete is disabled
      expect(find(".task-completed-section .error-message").text).to eq("Errors in form") # shows error

      # change to a different payment system
      find(".affiliation-field b[role='presentation']").click # open payment types dropdown
      find("div.select2-result-label", :text => /I will pay the full fee/).click # change back to non-pfa
      expect(find(".task-completed")[:disabled]).to be(nil) # not disabled after change
      expect(page).not_to have_selector(".task-completed-section .error-message") # make sure no error msg
    end
  end
end
