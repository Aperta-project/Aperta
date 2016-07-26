require 'rails_helper'

feature 'Billing Task', js: true do
  before do
    user  = create :user, :site_admin
    paper = create :paper_with_task,
                   :with_integration_journal,
                   creator: user,
                   task_params: { title: 'Billing',
                                  type: 'PlosBilling::BillingTask',
                                  old_role: 'author' }
    login_as user
    visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"
  end

  it 'shows validations', vcr: { cassette_name: 'ned_countries' } do
    p = PageFragment.new(find('.overlay'))
    p.select2('PLOS Publication Fee Assistance Program (PFA)',
              css: '.payment-method')

    within('.question-dataset') do
      find("input[id*='plos_billing--pfa_question_1-yes']").click
      find("input[id*='plos_billing--pfa_question_2-yes']").click
      find("input[id*='plos_billing--pfa_question_3-yes']").click
      find("input[id*='plos_billing--pfa_question_4-yes']").click

      # numeric fields
      idents = ['plos_billing--pfa_question_1b',
                'plos_billing--pfa_question_2b',
                'plos_billing--pfa_question_3a',
                'plos_billing--pfa_question_4a',
                'plos_billing--pfa_amount_to_pay']

      idents.each do |ident|
        find("input[name*='#{ident}']").set 'foo'
        page.execute_script("$(\"input[name*='#{ident}']\").blur()")
        expect(page).to have_css("#error-for-#{ident}",
          text: "Must be a number")
      end
    end
  end
end
