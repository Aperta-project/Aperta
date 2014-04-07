require 'spec_helper'

describe DeclarationsController do
  it "blahs" do
    expect(2).to eq 1
  end
  # before { sign_in user }

  # let(:declaration) { FactoryGirl.create(:declaration, question: "Who's the best?", answer: "PLOS")}

  # describe 'PATCH update' do
    # let(:permitted_params) { [:answer] }
    # subject(:do_request) do
    #   patch :update, {format: :json, id: declaration.to_param, answer: declaration.answer }
    # end

    # it_behaves_like "an unauthenticated json request"

    # it_behaves_like "a controller enforcing strong parameters" do
    #   let(:params_id) { declaration.to_param }
    #   let(:model_identifier) { :declaration }
    #   let(:expected_params) { permitted_params }
    # end
  # end
end
