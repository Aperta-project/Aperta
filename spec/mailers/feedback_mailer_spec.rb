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
include ClientRouteHelper

describe FeedbackMailer, redis: true do
  let(:app_name) { 'TEST-APP-NAME' }
  let(:user) { FactoryGirl.create(:user) }
  let(:feedback) {
    {
      referrer: "http://example.com/referrer",
      remarks: "Here is my feedback",
      screenshots: [{ url: "http://tahi.s3.amazonaws.com/pic.pdf", filename: "pic.pdf" }]
    }
  }
  let(:email) { FeedbackMailer.contact(user, feedback) }

  before do
    allow_any_instance_of(MailerHelper).to receive(:app_name).and_return app_name
    allow_any_instance_of(TemplateHelper)
  end

  describe "#contact" do
    it "has correct subject line" do
      expect(email.subject).to eq "[www.example.com] #{app_name} Feedback"
    end

    it "includes remarks in mailer body" do
      expect(email.body).to include feedback['remarks']
    end

    it "includes link to screenshots in mailer body" do
      expect(email.body).to include feedback['screenshots']
    end

    it 'Creates a log message with mail information after email sent' do
      Timecop.freeze do
        msg = "event=email to=admin@example.com from=#{user.email} subject="\
              "'[www.example.com] TEST-APP-NAME Feedback' at=#{Time.current}"
        expect(Rails.logger).to receive(:info).with(msg)
        email.deliver_now
      end
    end

    it 'Excludes styles that must be manually removed from auto-generated JIRA tickets' do
      expect(email.body).to_not include('<html>')
    end
  end
end
