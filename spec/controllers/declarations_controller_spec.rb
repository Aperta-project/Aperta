describe DeclarationsController do
  before { sign_in user }

  let(:declaration) { FactoryGirl.create(:declaration, question: "Who's the best?", answer: "PLOS")}

  describe 'PATCH update' do
    let(:permitted_params) { [:name] }
    let(:phase) { task_manager.phases.first }
    subject(:do_request) do
      patch :update, {format: :json, id: phase.to_param, phase: {name: 'Verify Signatures'} }
    end

    it_behaves_like "an unauthenticated json request"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:params_id) { phase.to_param }
      let(:model_identifier) { :phase }
      let(:expected_params) { permitted_params }
    end
  end
end
