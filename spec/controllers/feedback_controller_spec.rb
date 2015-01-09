require 'rails_helper'

describe FeedbackController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  def latest_email_body
    ActionMailer::Base.deliveries.first.body.parts.first.body
  end

  describe '#create' do
    context "with valid params" do

      before do
        ActionMailer::Base.deliveries.clear
        expect(ActionMailer::Base.deliveries.size).to eq 0

        post :create, {
          feedback: {
            remarks: 'some words',
            referrer: 'http://example.lvh.me'
          }
        }
      end

      it 'responds with 201' do
        expect(response.status).to eq 201
      end

      it "sends email" do
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(latest_email_body).to include 'some words'
      end

      it "includes the server environment" do
        expect(latest_email_body).to include 'test'
      end

      it "includes the originating url" do
        expect(latest_email_body)
          .to include 'http://example.lvh.me'
      end

    end
  end

end
