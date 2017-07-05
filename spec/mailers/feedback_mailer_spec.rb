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
      expect(email.body).to_not include('<style>')
    end
  end
end
