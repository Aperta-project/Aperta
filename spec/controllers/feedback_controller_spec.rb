require 'rails_helper'

describe FeedbackController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe '#create' do

    context "with valid params" do
      include ActiveJob::TestHelper

      before { ActionMailer::Base.deliveries.clear }
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

        expect(ActionMailer::Base.deliveries.size).to eq 1
        body = ActionMailer::Base.deliveries.first.body.parts.last.body
        expect(body).to include 'foo'
        expect(body).to include 'http://example.com'
        expect(body).to include 'test'
        expect(body).to include 'http://tahi.s3.amazonaws.com/pic.png'
      end
    end
  end

end
