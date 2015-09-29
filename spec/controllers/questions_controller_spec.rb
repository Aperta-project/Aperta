require 'rails_helper'

describe QuestionsController do

  expect_policy_enforcement

  let(:user) { create :user, :site_admin }
  let(:task) { FactoryGirl.create(:task) }
  let(:question) { FactoryGirl.create(:question) }
  let(:url) { "http://something" }

  before do
    sign_in user
  end

  shared_examples_for "processing attachments" do
    it "creates an question attachment" do
      expect { request_with_attachment }.to change { QuestionAttachment.count }.by(1)
    end

    it "queues a download worker" do
      request_with_attachment
      expect(DownloadQuestionAttachmentWorker).to have_queued_job(Question.last.question_attachment.id, url)
    end
  end

  describe "#index" do
    let!(:question1) { FactoryGirl.create(:question, task: task) }
    let!(:question2) { FactoryGirl.create(:question, task: task) }

    subject(:do_request) do
      get :index, {
            format: 'json',
            task_id: task.to_param,
          }
    end

    it "returns the tasks questions" do
      do_request
      expect(res_body['questions'].count).to eq(2)
      expect(res_body['questions'][0]['id']).to eq(question1.id)
    end
  end

  describe "#create" do
    let(:request_with_attachment) do
      post :create, format: :json, question: { task_id: task.id, ident: 'foo.bar', url: "http://something" }
    end

    it "succeeds" do
      post :create, format: :json, question: { task_id: task.id, ident: 'foo.bar' }
      expect(response.status).to eq(201)
    end

    it_behaves_like "processing attachments"
  end

  describe "#update" do
    let(:request_with_attachment) do
      put :update, format: :json, id: question.id, question: question.attributes.merge(url: url)
    end

    it "responds with 200 and json body" do
      put :update, format: :json, id: question.id, question: question.attributes.merge(answer: "42")
      expect(question.reload.answer).to eq("42")
      expect(response.status).to eq(200)
      expect(res_body).to have_key('question')
    end

    it_behaves_like "processing attachments"
  end
end
