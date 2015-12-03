require 'rails_helper'

feature 'Send to Apex task', js: true, selenium: true do
  include SidekiqHelperMethods

  let!(:user) { FactoryGirl.create(:user, :site_admin) }
  let!(:paper) { paper = FactoryGirl.create(:paper_ready_for_export) }
  let!(:task) { FactoryGirl.create(:send_to_apex_task, paper: paper) }
  let(:dashboard_page) { DashboardPage.new }
  let(:manuscript_page) { dashboard_page.view_submitted_paper paper }
  let!(:server) { FakeFtp::Server.new(21212, 21213) }

  before do
    server.start

    # Gotta ignore all those amazing expiration params
    VCR.configure do |c|
      c.default_cassette_options = {
        match_requests_on: [
          :method,
          VCR.request_matchers.uri_without_param(
            'X-Amz-Algorithm',
            'X-Amz-Credential',
            'X-Amz-Date',
            'X-Amz-Signature',
            'X-Amz-SignedHeaders')]
      }
    end

    task.participants << user
    paper.paper_roles.create!(user: user, role: PaperRole::COLLABORATOR)
    login_as(user, scope: :user)
    visit '/'
  end

  after do
    server.stop
  end

  scenario 'User can send a paper to Send to Apex' do
    apex_delivery = TahiStandardTasks::ApexDelivery.where(paper_id: paper.id)
    expect(apex_delivery.count).to be 0

    overlay = manuscript_page.view_card 'Send to Apex', SendToApexOverlay
    overlay.click_button('Send to Apex')
    overlay.ensure_apex_upload_is_pending

    VCR.use_cassette('send_to_apex') do
      process_sidekiq_jobs
      expect(server.files).to include(paper.manuscript_id + '.zip')
    end

    overlay.ensure_apex_upload_has_succeeded
  end
end
