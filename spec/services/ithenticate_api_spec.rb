require 'rails_helper'

feature 'iThenticate API', js: true do
  include SidekiqHelperMethods

  let!(:paper) do
    FactoryGirl.create(
      :paper,
      # :version_with_file_type,
      :ready_for_export,
      :with_creator
    )
  end
  let!(:task) do
    FactoryGirl.create(
      :similarity_check_task,
      paper: paper,
      phase: paper.phases.first
    )
  end
  let(:internal_editor) { FactoryGirl.create(:user) }
  let(:dashboard_page) { DashboardPage.new }
  let(:manuscript_page) { dashboard_page.view_submitted_paper paper }

  # This is a poor-man's XML field grabber. In iThenticate's use cases, we
  # want to avoid the overhead of full XML parsing in the case of the large
  # file POST. Since the field values we're interested in appear early in the
  # body, and use alphanumeric (plus period) values, a regex search, although
  # not proper for general XML parsing, is lighter-weight in this case.
  def get_field(field, req)
    m = /<#{field}>([\w.]+)/.match(req.body)
    m[1] if m.present?
  end

  before do
    # Matches the body of iThenticate POST requests, since the URIs and methods
    # are identical in all cases. This will interrogate the request body for
    # identifiers in the XML to find matching VCR responses to mocked requests.
    @post_regex_matcher = lambda do |app_request, vcr_request|
      matched = false
      if app_request.uri.index 'ithenticate'
        app_method = get_field('methodName', app_request)
        vcr_method = get_field('methodName', vcr_request)
        if app_method == vcr_method
          if app_method == 'login'
            # There are two mocked login requests, one with good credentials and
            # one with bad. They are small requests, hence the string compares.
            matched = app_request.body == vcr_request.body
          elsif app_method =~ /\.get$/
            # In both document.get and report.get requests, the ID you're
            # fetching appears in the "i4" field.
            matched = get_field('i4', app_request) == get_field('i4', vcr_request)
            # There is one mocked upload, so we only need a method name compare.
          elsif app_method == 'document.add'
            matched = true
          end
        end
        # TODO: delete puts here and below once you're confident matching is working as expected
        puts "Match for iThenticate method #{app_method}" if matched
      else
        matched = app_request.uri == vcr_request.uri || begin
          path = 'tahi-test.s3-us-west-1.amazonaws.com/uploads/paper/1/attachment/1/'
          app_request.uri.index(path) && vcr_request.uri.index(path)
        end
        puts "Match for #{app_request.uri}" if matched
      end
      matched
    end

    assign_internal_editor_role paper, internal_editor
    login_as(internal_editor, scope: :user)
    visit '/'
  end

  scenario 'User can generate a similarity check report' do
    similarity_check = SimilarityCheck.where(versioned_text_id: paper.versioned_texts.first.id)
    expect(similarity_check.count).to be 0

    overlay = Page.view_task_overlay(paper, task)
    overlay.click_button('Generate Report')
    overlay.click_button('Generate Report')
    VCR.use_cassette(
      'ithenticate_api',
      allow_playback_repeats: true,
      match_requests_on: [@post_regex_matcher],
      record: :none
    ) do
      process_sidekiq_jobs
      # TODO: wire up behaviors to check once they exist in the UI
      expect(page).to have_css('.fake_css_selector')
    end
  end
end
