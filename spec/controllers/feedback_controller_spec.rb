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

      before { allow(JIRAIntegrationService).to receive(:create_issue) }
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
