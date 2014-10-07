require 'spec_helper'

describe ParticipationsController do
  render_views
  let(:paper) { FactoryGirl.create(:paper, :with_tasks, user: user) }
  let(:phase) { paper.phases.first }
  let(:user) { create(:user) }

  let(:task) { create(:task, phase: phase) }
  before { sign_in user }

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create, format: :json,
        participation: {participant_id: user.id,
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
            participation: {participant_id: nil,
                            task_id: task.id}
          }.to_not change { Participation.count }
        end
      end

      it "creates a new participation" do
        do_request
        expect(Participation.last.participant.id).to eq(user.id)
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
end
