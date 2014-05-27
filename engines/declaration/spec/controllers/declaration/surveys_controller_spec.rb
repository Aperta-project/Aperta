require 'spec_helper'

module Declaration
  describe SurveysController do
    routes { Declaration::Engine.routes }
    let(:user) { create :user }
    before { sign_in user }

    let(:survey) { create(:survey, question: "Who's the best?", answer: "PLOS")}

    describe 'PATCH update' do
      subject(:do_request) do
        patch :update, {format: :json, id: survey.to_param, answer: survey.answer }
      end

      it_behaves_like "an unauthenticated json request"
    end
  end
end
