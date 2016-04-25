require 'rails_helper'

feature 'Send to Apex task', js: true, selenium: true do
  include SidekiqHelperMethods

  let!(:paper) do
    FactoryGirl.create(:paper_ready_for_export, :with_integration_journal)
  end
  let!(:task) do
    FactoryGirl.create(
      :send_to_apex_task,
      paper: paper,
      phase: paper.phases.first
    )
  end
  let(:internal_editor) { FactoryGirl.create(:user) }
  let(:dashboard_page) { DashboardPage.new }
  let(:manuscript_page) { dashboard_page.view_submitted_paper paper }
  let!(:server) { FakeFtp::Server.new(21212, 21213) }

  before do
    @start_with_matcher = lambda do |request_1, request_2|
      request_1.uri.start_with?(request_2.uri)
    end
    server.start

    assign_internal_editor_role paper, internal_editor

    login_as(internal_editor, scope: :user)
    visit '/'
  end

  after do
    server.stop
  end

  scenario 'User can send a paper to Send to Apex' do
    apex_delivery = TahiStandardTasks::ApexDelivery.where(paper_id: paper.id)
    expect(apex_delivery.count).to be 0

    overlay = Page.view_task_overlay(paper, task)
    overlay.click_button('Send to Apex')
    overlay.ensure_apex_upload_is_pending
    VCR.use_cassette('send_to_apex',
                     match_requests_on: [:method, @start_with_matcher]) do
      process_sidekiq_jobs
      expect(server.files).to include(paper.manuscript_id + '.zip')
    end

    overlay.ensure_apex_upload_has_succeeded
  end
end
