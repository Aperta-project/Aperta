require 'rails_helper'

describe PhasesController do
  let(:phase_name) { 'Verification' }
  let(:new_position) { 0 }
  let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let(:user) { FactoryGirl.create(:user) }

  describe 'POST create' do
    subject(:do_request) do
      post :create, format: :json, phase: {
        name: phase_name,
        paper_id: paper.id,
        position: new_position
      }
    end

    it_behaves_like "an unauthenticated json request"

    context 'and the user is authenticated' do
      before { stub_sign_in user }
      it_behaves_like "a forbidden json request"

      it "returns new the phase object as json" do
        expect(user).to receive(:can?).with(:manage_workflow, paper).and_return(true)
        do_request
        json = JSON.parse(response.body)
        expect(json["phase"]["id"]).to eq(Phase.last.id)
      end
    end
  end

  describe 'DELETE destroy' do
    let(:phase) { Phase.create paper_id: paper.id, position: 1 }

    subject(:do_request) do
      delete :destroy, format: :json, id: phase.id
    end

    it_behaves_like "an unauthenticated json request"

    context 'and the user is authenticated' do
      before { stub_sign_in user }
      it_behaves_like "a forbidden json request"

      context "and the phase has tasks" do
        before do
          phase.update!(
            tasks: [FactoryGirl.build(:ad_hoc_task, :with_loaded_card, paper: paper)]
          )
          expect(user).to receive(:can?).with(:manage_workflow, paper).and_return(true)
        end

        it 'responds with 400 BAD REQUEST' do
          do_request
          expect(response.status).to eq(400)
        end
      end

      context "and the phase does not have tasks" do
        before do
          expect(phase.tasks).to be_empty
          expect(user).to receive(:can?).with(:manage_workflow, paper).and_return(true)
        end

        it 'responds with 200 OK' do
          do_request
          expect(response.status).to eq(200)
        end
      end
    end
  end

  describe 'PATCH update' do
    let(:phase) { paper.phases.first }
    subject(:do_request) do
      patch :update, format: :json, id: phase.to_param, phase: { name: 'Verify Signatures' }
    end

    it_behaves_like "an unauthenticated json request"

    context 'and the user is authenticated' do
      before { stub_sign_in user }

      it_behaves_like "a forbidden json request"

      it "responds with 204 NO CONTENT" do
        expect(user).to receive(:can?).with(:manage_workflow, paper).and_return(true)
        do_request
        expect(response.status).to eq(204)
      end
    end
  end
end
