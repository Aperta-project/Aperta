require 'rails_helper'

# rubocop:disable Style/PercentLiteralDelimiters
feature 'Send to Apex task', js: true do
  include SidekiqHelperMethods

  let!(:paper) do
    FactoryGirl.create(
      :paper,
      :ready_for_export,
      :with_creator
    )
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
    @start_with_matcher = lambda do |app_request, vcr_request|
      # //tahi-test.s3-us-west-1.amazonaws.com/uploads/paper/1/attachment/1/ea85b0d61253e1033eab985b8ab1097187216cd45bce749956630c5914758bb9/about_turtles.docx|
      matched = false
      if app_request.method == vcr_request.method
        matched = app_request.uri == vcr_request.uri || begin
          regexp = %r|/uploads/paper/#{paper.id}/attachment/#{paper.file.id}/#{paper.file.file_hash}/#{paper.file.filename}|
          app_request.uri =~ regexp && vcr_request.uri =~ %r|/uploads/paper/\d+/attachment/\d+/[^\/]+/#{paper.file.filename}|
        end
      end
      matched
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
    VCR.use_cassette(
      'send_to_apex',
      allow_playback_repeats: true,
      match_requests_on: [:method, @start_with_matcher],
      record: :new_episodes
    ) do
      process_sidekiq_jobs
      expect(server.files).to include(paper.manuscript_id + '.zip')
    end

    overlay.ensure_apex_upload_has_succeeded
  end
end
# rubocop:enable Style/PercentLiteralDelimiters
