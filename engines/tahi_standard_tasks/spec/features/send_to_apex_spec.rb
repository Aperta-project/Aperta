require 'rails_helper'

feature 'Send to Apex task', js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:send_to_apex_task) }
  let(:paper) { task.paper }
  let(:dashboard_page) { DashboardPage.new }
  let(:manuscript_page) { dashboard_page.view_submitted_paper paper }

  before do
    task.participants << user
    paper.paper_roles.create!(user: user, role: PaperRole::COLLABORATOR)
    login_as(user, scope: :user)
    visit '/'
  end

  scenario 'User should be able to clearly trigger a "Send to Apex" action.' do
    manuscript_page.view_card 'Send to Apex' do |overlay|
      expect(overlay.find_button('Send to Apex'))
    end
  end
end
