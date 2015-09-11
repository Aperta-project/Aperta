require 'rails_helper'

describe NestedQuestionAnswersController do
  expect_policy_enforcement

  let(:user) { create :user, :site_admin }

  before do
    sign_in user
  end

  describe "#create" do
    let(:nested_question) { FactoryGirl.create(:nested_question) }
    let(:task) { nested_question.owner }

    def do_request
      post :create, nested_question_id: nested_question.to_param, nested_question_answer: { value: "Hello", task_id: task.id }, format: :json
    end

    it "creates an answer for the question" do
      expect {
        do_request
      }.to change(NestedQuestionAnswer, :count).by(1)

      answer = NestedQuestionAnswer.last
      expect(answer.nested_question).to eq(nested_question)
      expect(answer.owner).to eq(task)
      expect(answer.value).to eq("Hello")
    end

    it "responds with 204 No Content" do
      do_request
      expect(response.status).to eq(204)
    end
  end

  describe "#update" do
    let!(:nested_question_answer) { FactoryGirl.create(:nested_question_answer, value: "Hi") }
    let(:nested_question){ nested_question_answer.nested_question }
    let(:task){ nested_question.owner }

    def do_request
      put :update, id: nested_question_answer.to_param, nested_question_id: nested_question.to_param, nested_question_answer: { value: "Bye", task_id: task.id }, format: :json
    end

    it "updates the answer for the question" do
      expect {
        do_request
      }.to_not change(NestedQuestionAnswer, :count)

      answer = nested_question_answer.reload
      expect(answer.value).to eq("Bye")
    end

    it "responds with 204 No Content" do
      do_request
      expect(response.status).to eq(204)
    end
  end
end
