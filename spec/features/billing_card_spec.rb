require 'rails_helper'

feature 'Billing card', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) do
    FactoryGirl.create(
      :paper,
      :with_tasks,
      :with_integration_journal,
      creator: author
    )
  end
  let!(:billing_task) do
    FactoryGirl.create(
      :billing_task,
      completed: false,
      paper: paper,
      phase: paper.phases.first,
      title: "Billing"
    )
  end

  context 'As an author' do
    scenario 'validates billing card on completion', selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"

      overlay = Page.view_task_overlay(paper, billing_task)
      find_button('I am done with this task').click

      expect(page).to have_css('.error [name=plos_billing--first_name]')
      expect(page).to have_css('.error [name=plos_billing--last_name]')
      expect(page).to have_css('.error [name=plos_billing--department]')
      expect(page).to have_css('.error [name=plos_billing--phone_number]')
      expect(page).to have_css('.error [name=plos_billing--email]')
      expect(page).to have_css('.error.plos_billing--affiliation1')
      expect(page).to have_css('.error [name=plos_billing--address1]')
      expect(page).to have_css('.error [name=plos_billing--city]')
      expect(page).to have_css('.error [name=plos_billing--postal_code]')

      find('[name=plos_billing--first_name]').send_keys('first')
      find('[name=plos_billing--last_name]').send_keys('last')
      find('[name=plos_billing--department]').send_keys('department')
      find('[name=plos_billing--phone_number]').send_keys('415-555-5555')
      find('[name=plos_billing--email]').send_keys('author@plos.org')
      find('.plos_billing--affiliation1 input').send_keys('PLOS')
      find('[name=plos_billing--address1]').send_keys('address1')
      find('[name=plos_billing--city]').send_keys('city')
      find('[name=plos_billing--postal_code]').send_keys('postal_code')
      overlay.find('.payment-method .select2-arrow').click
      overlay.first('li.select2-result').click
      find_button('I am done with this task').click
      expect(overlay).to be_completed
    end
  end
end
