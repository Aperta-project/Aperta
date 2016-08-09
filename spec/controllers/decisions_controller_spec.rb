require 'rails_helper'

describe DecisionsController do
  let(:user) { FactoryGirl.build(:user) }
  let(:paper) { FactoryGirl.create(:paper, :submitted_lite) }
  let!(:revise_manuscript_task) { create :revise_task, paper: paper }

  describe "#update" do
    let(:decision) { paper.draft_decision }
    subject(:do_request) do
      put :update,
          format: :json,
          id: decision.id,
          decision: {}
    end

    it_behaves_like "an unauthenticated json request"

    context "a user is logged in" do
      before do
        stub_sign_in(user)
      end

      context 'and has no permissions' do
        let(:do_request) do
          put :update,
              format: :json,
              id: decision.id
        end

        it 'returns a 403' do
          do_request
          expect(response.status).to eq 403
        end
      end

      describe "updating the author response" do
        let(:author_response) { Faker::Lorem.paragraph(2) }
        subject(:do_request) do
          put :update,
              format: :json,
              id: decision.id,
              decision: {
                author_response: author_response
              }
        end

        context "the decision has been registered" do
          before do
            decision.update(
              registered_at: DateTime.now.utc, major_version: 0, minor_version: 0)
          end

          shared_examples_for "the author response is editable" do
            it "Updates the decision's author_response" do
              expect do
                do_request
                expect(response.status).to eq 200
              end.to change { decision.reload.author_response }.from(decision.author_response).to(author_response)
            end
          end

          context "the user has the permission to edit the ReviseManuscriptTask" do
            before do
              allow(user).to receive(:can?).with(:register_decision, paper).and_return(false)
              allow(user).to receive(:can?).with(:edit, revise_manuscript_task).and_return(true)
            end

            it_behaves_like "the author response is editable"

            # Testing this case because of the additive nature of permission granting in DecisionsController#update
            context "the user also has the permission to register a decision" do
              before do
                allow(user).to receive(:can?).with(:register_decision, paper).and_return(true)
              end

              it_behaves_like "the author response is editable"
            end
          end

          context "but the user does not have the permission to edit the ReviseManuscriptTask" do
            it "does not update the author_response" do
              expect do
                do_request
              end.not_to change { decision.reload.author_response }
              expect(response.status).to eq 403
            end
          end
        end
      end

      describe "updating the letter and verdict" do
        let(:new_letter) { Faker::Lorem.paragraph(2) }
        let(:new_verdict) { "accept" }
        subject(:do_request) do
          put :update,
              format: :json,
              id: decision.id,
              decision: {
                letter: new_letter,
                verdict: new_verdict
              }
        end

        context "the user has the permission to register a decision" do
          before do
            allow(user).to receive(:can?).with(:register_decision, paper).and_return(true)
            allow(user).to receive(:can?).with(:edit, revise_manuscript_task).and_return(false)
          end

          context "the decision is not registered" do
            it "updates the decision object" do
              expect do
                do_request
                decision.reload
              end.to change { [decision.letter, decision.verdict] }.to([new_letter, new_verdict])
            end
          end

          context "the decision is registered" do
            before do
              decision.update(registered_at: DateTime.now.utc, major_version: 0, minor_version: 0)
            end

            it "Returns a 422 and doesn't update the model" do
              expect do
                do_request
                decision.reload
              end.not_to change { [decision.verdict, decision.letter] }
              expect(response.status).to eq 422
              expect(res_body).to have(1).errors_on(:letter)
              expect(res_body).to have(1).errors_on(:verdict)
            end
          end
        end

        context "the user does not have the permission to register a decision" do
          it "does not update the letter or verdict" do
            expect do
              do_request
              decision.reload
            end.not_to change { [decision.verdict, decision.letter] }
            expect(response.status).to eq 403
          end
        end
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

    let(:decision) { paper.draft_decision }
    let(:task) do
      double("Task", id: 3, paper: paper).tap do |t|
        allow(t).to receive(:after_register)
        allow(t).to receive(:notify_requester=)
        allow(t).to receive(:answer_for)
        allow(t).to receive(:send_email)
      end
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
        expect(task).to receive(:after_register)
        do_request
      end

      it "renders the registered decision" do
        do_request
        expect(response.status).to be(200)
        expect(res_body.keys).to include('decisions')
      end

      it "posts to the activity stream" do
        expected_activity_1 = {
          message: "A decision was sent to the author",
          feed_name: "manuscript"
        }
        expected_activity_2 = {
          message: "A decision was made: Accept",
          feed_name: "workflow"
        }
        expected_activity_3 = {
          message: "Paper state changed to submitted",
          feed_name: "forensic"
        }
        expect(Activity).to receive(:create).with hash_including(expected_activity_1)
        expect(Activity).to receive(:create).with hash_including(expected_activity_2)
        expect(Activity).to receive(:create).with hash_including(expected_activity_3)
        do_request
      end

      describe "email" do
        it "is sent" do
          expect(task).to receive(:send_email)
          do_request
        end
      end

      context "the paper is unsubmitted" do
        before do
          paper.update(publishing_state: "unsubmitted")
        end

        it "Returns a 422" do
          do_request
          expect(response.status).to be(422)
          expect(res_body['errors'][0]).to eq("The paper must be submitted")
        end
      end

      context "the decision has no verdict" do
        before do
          decision.update(verdict: nil)
        end

        it "Returns a 422" do
          do_request
          expect(response.status).to be(422)
          expect(res_body['errors'][0]).to eq("You must pick a verdict, first")
        end
      end
    end
  end

  describe "#rescind" do
    subject(:do_request) do
      put :rescind,
          format: :json,
          id: decision.id
    end
    let(:decision) { paper.draft_decision }
    let(:paper) { FactoryGirl.create(:paper, :rejected_lite) }

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
          decision.update(verdict: "reject", registered_at: DateTime.now.utc, minor_version: 0, major_version: 0)
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

      context "the decision is not rescindable" do
        before do
          decision.update(registered_at: DateTime.now.utc)
        end

        it "Returns a 422" do
          do_request
          expect(response.status).to be(422)
          expect(res_body['errors'][0]).to eq("That decision is not rescindable")
        end
      end
    end
  end
end
