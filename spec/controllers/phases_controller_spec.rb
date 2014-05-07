require 'spec_helper'

describe PhasesController do

  let(:phase_name) { 'Verification' }
  let(:new_position) { 0 }
  let(:paper) { create(:paper) }
  let(:task_manager) { paper.task_manager }
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'POST create' do
    subject(:do_request) do
      post :create, format: :json, phase: {task_manager_id: task_manager.id,
                            name: phase_name,
                            paper_id: paper.id,
                            position: new_position}
    end

    it_behaves_like "an unauthenticated json request"

    it "returns new the phase object as json" do
      do_request
      json = JSON.parse(response.body)
      expect(json["phase"]["id"]).to eq(Phase.last.id)
    end
  end

  describe 'DELETE destroy' do
    it "with tasks" do
      phase = Phase.create tasks: [Task.new(title: "task", role: "author")], task_manager_id: 1, position: 1
      delete :destroy, format: :json, id: phase.id
      expect(response).to_not be_success
    end

    it "without tasks" do
      phase = Phase.create task_manager_id: 1, position: 1
      delete :destroy, format: :json, id: phase.id
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    let(:phase) { task_manager.phases.first }
    subject(:do_request) do
      patch :update, {format: :json, id: phase.to_param, phase: {name: 'Verify Signatures'} }
    end

    it_behaves_like "an unauthenticated json request"

    it "should be successful" do
      do_request
      expect(response).to be_success
    end
  end
end
