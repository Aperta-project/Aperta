require 'spec_helper'

describe SurveysController do
  let(:user) { FactoryGirl.create :user }
  before { sign_in user }

  let(:survey) { FactoryGirl.create(:survey, question: "Who's the best?", answer: "PLOS")}

  describe 'PATCH update' do
    subject(:do_request) do
      patch :update, {format: :json, id: survey.to_param, answer: survey.answer }
    end

    it_behaves_like "an unauthenticated json request"
  end
end
