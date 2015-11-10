require 'rails_helper'
include ClientRouteHelper

describe FeedbackMailer, redis: true do
  let(:app_name) { 'TEST-APP-NAME' }
  let(:user) { FactoryGirl.create(:user) }
  let(:feedback) {
    { referrer: "http://example.com/referrer",
      remarks: "Here is my feedback",
      screenshots: [{url: "http://tahi.s3.amazonaws.com/pic.pdf", filename: "pic.pdf"}]
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
  end
end
