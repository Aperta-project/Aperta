# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'support/pages/dashboard_page'
require 'support/sidekiq_helper_methods'

feature 'Similarity Check', js: true, redis: true do
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
          if app_method =~ /\.get$/
            # In both document.get and report.get requests, the ID you're
            # fetching appears in the "i4" field.
            matched = get_field('i4', app_request) == get_field('i4', vcr_request)
            # There is one mocked upload in the "good" cassette, and one login
            # in each cassette, so they only need a method name compare.
          elsif app_method =~ /^document\.add|login|folder\.list$/
            matched = true
          end
        end
      else
        matched = app_request.uri == vcr_request.uri || begin
          path = 'tahi-test.s3-us-west-1.amazonaws.com/uploads/paper/1/attachment/1/'
          app_request.uri.index(path) && vcr_request.uri.index(path)
        end
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
      # TODO: Change this to expect a web page effect once the card is updated
      expect { process_sidekiq_jobs }.to_not raise_error
    end
  end

  scenario 'Bad iThenticate credentials raises an exception' do
    similarity_check = SimilarityCheck.where(versioned_text_id: paper.versioned_texts.first.id)
    expect(similarity_check.count).to be 0

    overlay = Page.view_task_overlay(paper, task)
    overlay.click_button('Generate Report')
    overlay.click_button('Generate Report')
    VCR.use_cassette(
      'ithenticate_api_bad_creds',
      allow_playback_repeats: true,
      match_requests_on: [@post_regex_matcher],
      record: :none
    ) do
      expect { process_sidekiq_jobs }.to raise_error RuntimeError
    end
  end
end
