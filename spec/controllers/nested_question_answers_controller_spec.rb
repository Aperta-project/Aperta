require 'rails_helper'

describe NestedQuestionAnswersController do
  let(:user) { FactoryGirl.create :user }
  let(:card_content) { FactoryGirl.create(:card_content) }
  let(:owner) { FactoryGirl.create(:ad_hoc_task) }

  describe "#create" do
    subject(:do_request) do
      post_params = {
        format: 'json',
        nested_question_id: card_content.id,
        nested_question_answer: {
          value: "Hello",
          owner_id: owner.id,
          owner_type: owner.class.name,
          additional_data: { "institution-id" => "123" }
        }
      }
      post(:create, post_params)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, owner)
          .and_return true
      end

      it "creates an answer for the question" do
        expect do
          do_request
        end.to change(Answer, :count).by(1)

        answer = Answer.last
        expect(answer.card_content).to eq(card_content)
        expect(answer.owner).to eq(owner)
        expect(answer.value).to eq("Hello")
        expect(answer.additional_data).to eq("institution-id" => "123")
      end

      it "responds with 200 OK" do
        do_request
        expect(response.status).to eq(200)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, owner)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#create with an existing answer for the owner" do
    subject(:do_request) do
      post_params = {
        format: 'json',
        nested_question_id: card_content.id,
        nested_question_answer: {
          value: "bar",
          owner_id: owner.id,
          owner_type: owner.type,
          additional_data: { "institution-id" => "123" }
        }
      }
      post(:create, post_params)
    end

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, owner)
          .and_return true
      end

      it "finds the existing answer and updates it instead of creating a new one" do
        answer = FactoryGirl.create(
          :answer,
          card_content: card_content,
          value: "foo",
          owner: owner,
          paper: owner.paper
        )

        expect do
          do_request
        end.to_not change(Answer, :count)

        expect(answer.reload.value).to eq("bar")
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, owner)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#update" do
    let!(:answer) { FactoryGirl.create(:answer, value: "Hi", card_content: card_content, owner: owner) }
    let(:card_content) { FactoryGirl.create(:card_content) }

    subject(:do_request) do
      put_params = {
        format: 'json',
        id: answer.to_param,
        nested_question_id: card_content.to_param,
        nested_question_answer: {
          value: "Bye",
          owner_id: owner.id,
          owner_type: owner.type,
          additional_data: { "institution-id" => "234" }
        }
      }
      put(:update, put_params)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, owner)
          .and_return true
      end

      it "updates the answer for the question" do
        expect do
          do_request
        end.to_not change(Answer, :count)

        answer.reload
        expect(answer.value).to eq("Bye")
        expect(answer.additional_data).to eq("institution-id" => "234")
      end

      it "responds with 200 OK" do
        do_request
        expect(response.status).to eq(200)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, owner)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#destroy" do
    let!(:answer) { FactoryGirl.create(:answer, value: "Hi", owner: owner) }
    let(:card_content) { FactoryGirl.create(:card_content) }

    subject(:do_request) do
      delete_params = {
        format: 'json',
        id: answer.to_param,
        nested_question_id: card_content.to_param
      }
      delete(:destroy, delete_params)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, owner)
          .and_return true
      end

      it "deletes the answer for the question" do
        expect do
          do_request
        end.to change(Answer, :count).by(-1)
      end

      it "sets deleted_at" do
        do_request
        answer.reload
        expect(answer.deleted_at).to_not be_nil
      end

      it "responds with 204" do
        do_request
        expect(response.status).to eq(204)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, owner)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
