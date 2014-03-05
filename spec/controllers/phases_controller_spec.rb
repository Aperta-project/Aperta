require 'spec_helper'

describe PhasesController do

  let(:phase_name) { 'Verification' }
  let(:new_position) { 0 }
  let!(:task_manager) { TaskManager.create! }
  let(:user) { FactoryGirl.create(:user) }

  before { sign_in user }

  describe 'POST create' do
    let(:permitted_params) { [:task_manager_id, :name, :position] }
    subject(:do_request) do
      post :create, format: :json, phase: {task_manager_id: task_manager.id,
                            name: phase_name,
                            position: new_position}
    end

    it_behaves_like "an unauthenticated json request"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:model_identifier) { :phase }
      let(:expected_params) { permitted_params }
    end
  end


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
