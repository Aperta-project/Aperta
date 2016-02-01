require 'rails_helper'

describe NestedQuestionAnswersController do
  let(:user) { create :user, :site_admin }
  let(:nested_question) { FactoryGirl.create(:nested_question) }

  before do
    sign_in user
  end

  describe "#create" do
    let!(:owner) { nested_question.owner }

    def do_request(params: {})
      post_params = {
        format: 'json',
        nested_question_id: nested_question.to_param,
        nested_question_answer: {
          value: "Hello",
          owner_id: owner.id,
          owner_type: owner.type,
          additional_data: { "insitution-id" => "123" }
        }.merge(params)
      }
      post(:create, post_params, format: :json)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, owner)
          .and_return true
      end

      it "creates an answer for the question" do
        expect do
          do_request
        end.to change(NestedQuestionAnswer, :count).by(1)

        answer = NestedQuestionAnswer.last
        expect(answer.nested_question).to eq(nested_question)
        expect(answer.owner).to eq(owner)
        expect(answer.value).to eq("Hello")
        expect(answer.additional_data).to eq("insitution-id" => "123")
      end

      it "responds with 200 OK" do
        do_request
        expect(response.status).to eq(200)
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, owner)
          .and_return false
      end

      it { responds_with(403) }
    end
  end

  describe "#create with an existing answer for the owner" do
    let(:owner) { nested_question.owner }

    def do_request(params: {})
      post_params = {
        nested_question_id: nested_question.to_param,
        nested_question_answer: {
          value: "bar",
          owner_id: owner.id,
          owner_type: owner.type,
          additional_data: { "insitution-id" => "123" }
        }.merge(params)
      }
      post(:create, post_params, format: :json)
    end

    context "when the user has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, owner)
          .and_return true
      end

      it "finds the existing answer and updates it instead of creating a new one" do
        answer = FactoryGirl.create(
          :nested_question_answer,
          nested_question: nested_question, value: "foo",
          owner_type: owner.type,
          owner_id: owner.id)

        expect do
          do_request
        end.to_not change(NestedQuestionAnswer, :count)

        expect(answer.reload.value).to eq("bar")
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, owner)
          .and_return false
      end

      it { responds_with(403) }
    end
  end

  describe "#update" do
    let!(:nested_question_answer) { FactoryGirl.create(:nested_question_answer, value: "Hi", owner: nested_question.owner) }
    let(:nested_question) { FactoryGirl.create(:nested_question) }
    let(:owner) { nested_question.owner }

    def do_request(params:{})
      put_params = {
        id: nested_question_answer.to_param,
        nested_question_id: nested_question.to_param,
        nested_question_answer: {
          value: "Bye",
          owner_id: owner.id,
          owner_type: owner.type,
          additional_data: { "insitution-id" => "234" }
        }.merge(params)
      }
      put(:update, put_params, format: :json)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, owner)
          .and_return true
      end

      it "updates the answer for the question" do
        expect do
          do_request
        end.to_not change(NestedQuestionAnswer, :count)

        answer = nested_question_answer.reload
        expect(answer.value).to eq("Bye")
        expect(answer.additional_data).to eq("insitution-id" => "234")
      end

      it "responds with 200 OK" do
        do_request
        expect(response.status).to eq(200)
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, owner)
          .and_return false
      end

      it { responds_with(403) }
    end
  end

  describe "#destroy" do
    let!(:nested_question_answer) { FactoryGirl.create(:nested_question_answer, value: "Hi", owner: nested_question.owner) }
    let(:nested_question) { FactoryGirl.create(:nested_question) }
    let(:owner) { nested_question.owner }

    def do_request(params:{})
      delete_params = {
        id: nested_question_answer.to_param,
        nested_question_id: nested_question.to_param,
        nested_question_answer: {
          value: "Bye",
          owner_id: owner.id,
          owner_type: owner.type,
          additional_data: { "insitution-id" => "234" }
        }.merge(params)
      }
      delete(:destroy, delete_params, format: :json)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, owner)
          .and_return true
      end

      it "deletes the answer for the question" do
        expect do
          do_request
        end.to change(NestedQuestionAnswer, :count).by(-1)

        expect do
          nested_question_answer.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "responds with 200 OK" do
        do_request
        expect(response.status).to eq(200)
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, owner)
          .and_return false
      end

      it { responds_with(403) }
    end
  end
end
