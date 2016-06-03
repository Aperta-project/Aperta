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

    context "a user is logged in who may not register decisions" do
      before do
        allow(user).to receive(:can?)
          .with(:register_decision, paper)
          .and_return false

        stub_sign_in(user)
      end

      it "returns a 403" do
        do_request
        expect(response.status).to be(403)
      end
    end

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

    context "a user is logged in who may not register decisions" do
      before do
        allow(user).to receive(:can?)
          .with(:register_decision, paper)
          .and_return false

        stub_sign_in(user)
      end

      it "returns a 403" do
        do_request
        expect(response.status).to be(403)
      end
    end

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

    context "a user is logged in who may not register decisions" do
      before do
        allow(user).to receive(:can?)
          .with(:register_decision, paper)
          .and_return false

        stub_sign_in(user)
      end

      it "returns a 403" do
        do_request
        expect(response.status).to be(403)
      end
    end

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
  end

  describe "#rescind" do
    subject(:do_request) do
      put :rescind,
          format: :json,
          id: decision.id
    end
    let(:decision) { paper.decisions.latest }
    let(:paper) { FactoryGirl.create(:paper, publishing_state: :rejected) }

    it_behaves_like "an unauthenticated json request"

    context "a user is logged in who may not rescind decisions" do
      before do
        allow(user).to receive(:can?)
          .with(:rescind_decision, paper)
          .and_return false

        stub_sign_in(user)
      end

      it "returns a 403" do
        do_request
        expect(response.status).to be(403)
      end
    end

    context "and the user is signed in" do
      before do
        allow(user).to receive(:can?)
          .with(:rescind_decision, paper)
          .and_return true
        stub_sign_in(user)
      end

      context "and the decision is rescindable" do
        before do
          decision.update(verdict: "reject", registered: true)
        end

        it "completes successfully" do
          do_request
          expect(response.status).to eq(200)
        end

        it "rescinds the latest decision" do
          do_request
          expect(paper.reload.publishing_state).to eq("initially_submitted")
          expect(decision.reload.rescinded).to be(true)
        end
      end
    end
  end
end
