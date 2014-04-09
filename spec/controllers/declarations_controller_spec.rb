require 'spec_helper'

describe DeclarationsController do
  let(:user) { FactoryGirl.create :user }
  before { sign_in user }

  let(:declaration) { FactoryGirl.create(:declaration, question: "Who's the best?", answer: "PLOS")}

  describe 'PATCH update' do
    subject(:do_request) do
      patch :update, {format: :json, id: declaration.to_param, answer: declaration.answer }
    end

    it_behaves_like "an unauthenticated json request"
  end
end
