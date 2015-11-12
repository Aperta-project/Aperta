require 'rails_helper'

feature 'Send to Apex task', js: true do
  include SidekiqHelperMethods

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:task) { FactoryGirl.create(:send_to_apex_task, paper: paper) }
  let(:dashboard_page) { DashboardPage.new }
  let(:manuscript_page) { dashboard_page.view_submitted_paper paper }

  before do
    task.participants << user
    paper.paper_roles.create!(user: user, role: PaperRole::COLLABORATOR)
    login_as(user, scope: :user)
    visit '/'
  end

  scenario 'User can send a paper to Send to Apex' do
    apex_delivery = TahiStandardTasks::ApexDelivery.where(paper_id: paper.id)
    expect(apex_delivery.count).to be 0

    overlay = manuscript_page.view_card 'Send to Apex', SendToApexOverlay
    overlay.click_button('Send to Apex')
    overlay.ensure_apex_upload_is_pending

    process_sidekiq_jobs
    overlay.ensure_apex_upload_has_succeeded
  end
end
