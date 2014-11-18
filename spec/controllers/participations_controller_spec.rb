require 'spec_helper'

describe ParticipationsController do
  render_views
  let!(:paper) { FactoryGirl.create(:paper, :with_tasks, creator: user) }
  let(:phase) { paper.phases.first }
  let(:user) { create(:user) }

  let(:task) { create(:task, phase: phase) }
  before { sign_in user }

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create, format: :json,
        participation: {user_id: user.id,
                        task_id: task.id}
    end

    context "the user isn't authorized" do
      authorize_policy(ParticipationsPolicy, false)

      it "renders 403" do
        do_request
        expect(response.status).to eq(403)
      end
    end

    context "the user is authorized" do
      authorize_policy(ParticipationsPolicy, true)

      context "the user does not pass a participant" do
        it "doesn't work" do
          expect {
            xhr :post, :create,
            format: :json,
            participation: {user_id: nil,
                            task_id: task.id}
          }.to_not change { Participation.count }
        end
      end

      it "creates a new participation" do
        expect{ do_request }.to change(Participation, :count).by(1)
      end

      it "returns the new participation as json" do
        do_request
        expect(response.status).to eq(201)
        json = JSON.parse(response.body)
        expect(json["participation"]["id"]).to eq(Participation.last.id)
      end
      it_behaves_like "an unauthenticated json request"
    end
  end

  describe "DELETE #destroy" do
    authorize_policy(ParticipationsPolicy, true)

    context "with a valid participation id" do
      let(:do_request) do
        delete :destroy, format: :json, id: participation.id
      end

      let!(:participation) { FactoryGirl.create :participation }

      it "destroys the associated author" do
        expect {
          do_request
        }.to change { Participation.count }.by -1
      end
    end

    context "with an invalid participation id" do
      let(:do_request) do
        delete :destroy, format: :json, id: 9999
      end

      it "returns a 404" do
        expect(do_request.status).to eq(404)
      end
    end
  end

  context "participants" do
    authorize_policy(ParticipationsPolicy, true)

    let(:task) { FactoryGirl.create(:task) }
    let(:new_participant) { FactoryGirl.create(:user) }

    it "adds an email to the sidekiq queue if new participant is not current user" do
      expect {
        post :create, format: 'json', participation: { user_id: new_participant.id, task_id: task.id }
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
    end

    it "does not add an email to the sidekiq queue if new participant is the current user" do
      expect {
        post :create, format: 'json', participation: { user_id: user.id, task_id: task.id }
      }.to_not change(Sidekiq::Extensions::DelayedMailer.jobs, :size)
    end
  end
end
