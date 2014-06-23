require 'spec_helper'

describe QuestionsController do

  expect_policy_enforcement

  let(:user) { FactoryGirl.create(:user, :admin) }
  let(:task) { FactoryGirl.create(:task) }
  let(:question) { FactoryGirl.create(:question) }

  before do
    sign_in user
  end

  describe "#create" do
    it "succeeds" do
      post :create, format: :json, question: { task_id: task.id, ident: 'foo.bar' }
      expect(response.status).to eq(201)
    end
  end

  describe "#update" do
    it "responds with 200 and json body" do
      put :update, format: :json, id: question.id, question: question.attributes.merge(answer: "42")
      expect(question.reload.answer).to eq("42")
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to have_key('question')
    end
  end
end
