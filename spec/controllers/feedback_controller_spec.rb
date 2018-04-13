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

describe FeedbackController do
  let(:user) { FactoryGirl.create(:user) }

  before do
    FactoryGirl.create :feature_flag, name: 'JIRA_INTEGRATION'
    sign_in user
  end

  describe '#create' do

    context "with valid params" do
      include ActiveJob::TestHelper

      before { allow(Jira).to receive(:create_issue) }
      after  { clear_enqueued_jobs }

      let(:valid_params){ {remarks: 'foo', referrer: 'http://example.com',
      screenshots: [{url: "http://tahi.s3.amazonaws.com/pic.png", filename: "pic.png"}] }}

      it 'responds with 201' do
        post :create, feedback: valid_params
        expect(response.status).to eq 201
      end

      it "send email with enviroment, feedback test and referrer" do
        perform_enqueued_jobs do
          post :create, feedback: valid_params
        end

        open_email('admin@example.com')
        expect(current_email).to have_body_text('http://example.com')
        expect(current_email).to have_body_text('test')
        expect(current_email).to have_body_text('http://tahi.s3.amazonaws.com/pic.png')
      end
    end
  end
end
