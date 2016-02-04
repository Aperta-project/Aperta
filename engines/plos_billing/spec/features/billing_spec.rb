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

      within(".question-dataset") do
        find("input[id*='plos_billing--pfa_question_1-yes']").click
        find("input[id*='plos_billing--pfa_question_2-yes']").click
        find("input[id*='plos_billing--pfa_question_3-yes']").click
        find("input[id*='plos_billing--pfa_question_4-yes']").click

        # numeric fields
        ['plos_billing--pfa_question_1b', 'plos_billing--pfa_question_2b', 'plos_billing--pfa_question_3a', 'plos_billing--pfa_question_4a', 'plos_billing--pfa_amount_to_pay'].each do |ident|
          find("input[name*='#{ident}']").set 'foo'
          page.execute_script("$(\"input[name*='#{ident}']\").blur()")
          expect(find("#error-for-#{ident}")).to have_content("Must be a number and contain no symbols, or letters")
        end
      end
    end
  end
end
