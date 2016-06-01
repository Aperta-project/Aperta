require 'rails_helper'

describe DecisionsController do
  let(:user) { FactoryGirl.build(:user) }

  let(:paper) do
    FactoryGirl.create(:paper)
  end

  describe "#create" do
    subject(:do_request) do
      post :create,
           format: :json,
           decision: { paper_id: paper.id }
    end

    it_behaves_like "an unauthenticated json request"

    context "a user is logged in who may register decisions" do
      before do
        allow(user).to receive(:can?)
          .with(:register_decision, paper)
          .and_return true

        stub_sign_in(user)
      end

      it "creates a decision" do
        expect { do_request }.to change { paper.decisions.count }.by 1
      end
    end
  end

  describe "#update" do
    let(:new_letter) { "Positive Words in a Letter" }
    let(:new_verdict) { "accept" }
    let(:decision) { paper.decisions.latest }

    subject(:do_request) do
      put :update,
          format: :json,
          id: decision.id,
          decision: {
            letter: new_letter,
            verdict: new_verdict
          }
    end

    it_behaves_like "an unauthenticated json request"

    context "a user is logged in who may register decisions" do
      before do
        allow(user).to receive(:can?)
          .with(:register_decision, paper)
          .and_return true

        stub_sign_in(user)
      end

      it "updates the decision object" do
        do_request
        decision.reload
        expect(decision.letter).to eq(new_letter)
        expect(decision.verdict).to eq(new_verdict)
      end
    end
  end

  describe "#register" do
    subject(:do_request) do
      put :register,
          format: :json,
          id: decision.id,
          task_id: task.id
    end

    let(:decision) { paper.decisions.latest }
    let(:task) do
      dub = double("Task", id: 3, paper: paper)
      allow(dub).to receive(:register)
      allow(dub).to receive(:notify_requester=)
      dub
    end

    before do
      paper.update(publishing_state: "submitted")
      decision.update(verdict: "accept")
    end

    it_behaves_like "an unauthenticated json request"

    context "when a user is logged in who may register decisions" do
      before do
        allow(user).to receive(:can?)
          .with(:register_decision, paper)
          .and_return true

        stub_sign_in(user)

        allow(Task).to receive(:find).with(task.id).and_return(task)
      end

      it "tells the task to register the decision" do
        expect(task).to receive(:register)
        do_request
      end

      it "renders the registered decision" do
        do_request
        expect(response.status).to be(200)
        expect(res_body.keys).to include('decisions')
      end

      it "posts to the activity stream" do
        expected_activity = {
          message: "Accept was sent to author",
          feed_name: "workflow"
        }
        expect(Activity).to receive(:create).with hash_including(expected_activity)
        do_request
      end
    end

    context "assigns @decision" do
      it "updates letter and verdict" do
        expect(assigns(:decision).letter).to eq new_letter
        expect(assigns(:decision).verdict).to eq new_verdict
      end

      it "does not update revision_number" do
        expect(assigns(:decision).revision_number).to_not eq 99
        expect(assigns(:decision).revision_number).to eq 0
      end
    end
  end
end
